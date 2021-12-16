class SprintsController < ApplicationController
  before_action :set_sprint, only: [:show, :edit, :update, :destroy, :start, :suspend, :finish, :team_summary, :retrospective_report]

  def index
  	@project = Project.find(params[:project_id])
  	sprints = @project.sprints
  	@sprints = sprints.select do |sprint|
  		can? :read, sprint
  	end
    if params["current"] == "true"
      @sprints = @sprints.select do |sprint|
        !sprint.completed
      end
    elsif params["completed"] == "true"
      @sprints = @sprints.select do |sprint|
        sprint.completed
      end
      @sprints = @sprints.sort_by { |s| s.actual_end_date }.reverse
    end
  end

  def show
  	check { can? :read, @sprint }
  end

  def update
    check { can? :update, @sprint }

    Sprint.transaction do
      params = sprint_params

      order = params[:order]
      params.delete(:order)
      if order
        @sprint.update!(issue_order: order)
        sync_on "sprints/#{@sprint.id}/issues"
        Activity.create(user: current_user, action: "reordered_issues", sprint: @sprint, project_context: @sprint.project)
      end

      @sprint.project.update_burndown_data!

      @sprint.update!(params)
      sync_on "sprints/#{@sprint.id}"
      sync_on_activities(@sprint.project)
      Activity.create(user: current_user, action: "updated_sprint", sprint: @sprint, project_context: @sprint.project)
    end
  end

  def create
    Sprint.transaction do
      @project = Project.find(request.params[:project_id])
      @sprint = Sprint.create(sprint_params.merge(project: @project))
      sync_on "projects/#{@sprint.project_id}/sprints"
      sync_on_activities(@project)

      record_action
      Activity.create(user: current_user, action: "created_sprint", sprint: @sprint, project_context: @sprint.project)
    end
  end

  def destroy
    Sprint.transaction do
      @sprint = Sprint.find(params[:id])
      if !@sprint
        raise ActionController::RoutingError, "Not Found"
      end 

      check { can? :delete, @sprint }
      @project = @sprint.project

      @sprint.issues.each { |issue| issue.update(sprint: nil) }

      if @sprint.delete

        record_action
        sync_on "projects/#{@project.id}/sprints"
        render json: { result: "success" }, status: :ok, location: @project
        sync_on_activities(@project)
        Activity.create(user: current_user, action: "deleted_sprint", modifier: "#{@sprint.id} - #{@sprint.title}", project_context: @sprint.project)
      else
        render json: @sprint.errors, status: :unprocessable_entity
      end
    end
  end

  def remove_issue
    Sprint.transaction do
      issue_params = params.require(:issue).permit(:id)
      issue_id = issue_params['id']
      sprint_id = request.params[:sprint_id]

      issue = Issue.find(issue_id)
      @sprint = Sprint.find(sprint_id)
      _assert(ArgumentError, "issue does not belong to sprint") { issue.sprint == @sprint }

      issue.update!(sprint: nil)
      @sprint.update!(issue_order: remove_from_order(@sprint.issue_order, issue_id))
      issue.project.update!(issue_order: append_to_order(issue.project.issue_order, issue_id))
      
      @sprint.project.update_burndown_data!

      record_action

      Activity.create(user: current_user, action: "removed_issue_from_sprint", issue: issue, sprint: @sprint, project_context: @sprint.project)
      sync_on "issues/#{issue_id}"
      sync_on "issues/*"
      sync_on "sprints/#{sprint_id}"
      sync_on "sprints/#{sprint_id}/issues"
      sync_on "sprints/#{sprint_id}/issues/*"
      sync_on "sprints/#{sprint_id}/team_summary"
      sync_on "projects/#{issue.project.id}/issues"
      sync_on "projects/#{issue.project.id}/issues/*"
      sync_on_activities(issue.project)
    end
  end

  def add_issue
    Epic.transaction do
      add_params = params.require(:issue).permit(:issue_id)
      issue_id = add_params[:issue_id]
      sprint_id = request.params[:sprint_id]

      issue = Issue.find(issue_id)
      project =  issue.project
      @sprint = Sprint.find(sprint_id)
      check { can? :update, @sprint }
      check { can? :update, issue }
      _assert(ArgumentError, "issue already belongs to sprint") { issue.sprint != @sprint }

      original_sprint = issue.sprint
      issue.update!(sprint: @sprint)
      if original_sprint
        check { can? :update, original_sprint }
        original_sprint.update!(issue_order: remove_from_order(original_sprint.issue_order, issue_id))
      else
        check { can? :update, project }
        project.update!(issue_order: remove_from_order(project.issue_order, issue_id))
      end
      @sprint.update!(issue_order: append_to_order(@sprint.issue_order, issue_id))

      if !original_sprint
        Activity.create(user: current_user, action: "added_issue_to_sprint", issue: issue, sprint: @sprint, project_context: @sprint.project)
      else
        Activity.create(user: current_user, action: "moved_issue_between_sprints", issue: issue, sprint: original_sprint, sprint2: @sprint, project_context: @sprint.project)
      end

      sync_on "issues/#{issue_id}"
      sync_on "projects/#{issue.project.id}/issues/*"
      sync_on "sprints/#{issue.sprint_id}/issues/*"
      sync_on "sprints/#{sprint_id}"
      sync_on "sprints/#{sprint_id}/issues"

      if original_sprint
        sync_on "sprints/#{original_sprint.id}"
        sync_on "sprints/#{original_sprint.id}/issues"
      end

      record_action
        
      sync_on_activities(@sprint.project)
    end
  end

  def reorder_issues
    Sprint.transaction do
      sprint_id = params[:sprint_id]
      @sprint = Sprint.find(sprint_id)
      safe_params = params.require(:data).permit(:fromIndex, :toIndex)
      order = @sprint.issue_order || default_issue_order(@sprint)
      order_split = order.split(',')
      order_split.insert(safe_params[:toIndex].to_i, order_split.delete_at(safe_params[:fromIndex].to_i))

      @sprint.update(issue_order: order_split.join(','))
      sync_on "sprints/#{sprint_id}/issues"
      sync_on "sprints/#{sprint_id}"
      sync_on_activities(@sprint.project)

      record_action

      Activity.create(user: current_user, action: "reordered_issues", sprint: @sprint, project_context: @sprint.project)
    end
  end

  def start
    Sprint.transaction do
      unless @project.current_sprint
        start_params = params.require(:data).permit(:startDate, :endDate, :reset)
        check { can? :start, @sprint }
        if @project.update(current_sprint: @sprint)

          if start_params[:reset] || (@sprint.start_date != start_params[:startDate])
            clear_burndown_data(@sprint)
            starting_work = @sprint.issues.sum(:estimate)
            @sprint.update!(starting_work: starting_work)
          end

          @sprint.update!(started: true, start_date: start_params[:startDate], end_date: start_params[:endDate])

          @project.update_burndown_data!

          record_action

          Activity.create(user: current_user, action: "started_sprint", sprint: @sprint, project: @project, project_context: @project)
          sync_on "sprints/#{@sprint.id}"
          sync_on "projects/#{@project.id}"
          sync_on "projects/#{@project.id}/sprints"
          sync_on_activities(@project)
          render json: { message: "Current sprint set" }, status: :ok
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      else
        render json: { message: "Current sprint already set" }, status: :bad_request
      end 
    end
  end

  def suspend
    if @project.current_sprint
      check { can? :suspend, @project.current_sprint }
      if @project.update(current_sprint: nil)
        Activity.create(user: current_user, action: "suspended_sprint", sprint: @sprint, project: @project, project_context: @project)
        sync_on "sprints/#{@sprint.id}"
        sync_on "projects/#{@project.id}"
        sync_on "projects/#{@project.id}/sprints"
        sync_on_activities(@project)

        record_action
        render json: { message: "Current sprint suspended" }, status: :ok
      else
        render json: @project.errors, status: :unprocessable_entity
      end
    else
      render json: { message: "Current sprint not set" }, status: :bad_request
    end 
  end

  def finish
    Sprint.transaction do
      if @project.current_sprint
        check { can? :finish, @project.current_sprint }
        @project.update!(current_sprint: nil)
        @sprint.update!(completed: true, actual_end_date: Date.today)

        closed_issues = @sprint.issues.where("state = 'Closed'")
        closed_issues.each { |issue| issue.update!(completed: true) }

        record_action

        Activity.create(user: current_user, action: "finished_sprint", sprint: @sprint, project: @project, project_context: @project)
        sync_on "sprints/#{@sprint.id}"
        sync_on "sprints/#{@sprint.id}/issues"
        sync_on "sprints/#{@sprint.id}/issues/*"
        sync_on "projects/#{@project.id}"
        sync_on "projects/#{@project.id}/sprints"
        sync_on_activities(@project)
        render json: { message: "Current sprint finished" }, status: :ok
      else
        render json: { message: "Current sprint not set" }, status: :bad_request
      end
    end
  end

  def team_summary
    check { can? :read, @sprint }
    @sprint
  end

  def retrospective_report
    check { can? :read, @sprint }
    @sprint
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sprint
      @sprint = Sprint.find(params[:id] || params[:sprint_id])
      @project = @sprint.project
    end

    # Only allow a list of trusted parameters through.
    def sprint_params
      params.require(:sprint).permit(:title, :goal, :description, :retrospective)
    end

    def clear_burndown_data(sprint)
      sprint.clear_burndown_data!
    end
end

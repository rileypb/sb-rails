class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update]


 
  def index
  	@project = params[:project_id] && Project.find(params[:project_id])
  	@sprint = params[:sprint_id] ? Sprint.find(params[:sprint_id]) : nil
    @epic = params[:epic_id] ? Epic.find(params[:epic_id]) : nil
    @project = @project || (@sprint && @sprint.project) || (@epic && @epic.project)
    if @epic 
      @parent = @epic
  	elsif @sprint
  		@parent = @sprint
  	else
  		@parent = @project
  	end

    check { can? :read, @project }
    check { can? :read, @sprint } if @sprint
    check { can? :read, @epic } if @epic

  	iss = @parent.issues
    order = (@parent.issue_order || '').split(',')
    @issues = []
    order.each do |i|
      this_issue = iss.find(i) rescue nil
      if this_issue
        @issues << this_issue
      end
    end
    iss.each do |i|
      @issues << i if !@issues.include?(i)
    end
  end

  def all_issues
    @project = params[:project_id] && Project.find(params[:project_id])

    check { can? :read, @project }

    @issues = @project.issues
  end

  def show
  	if !@issue
  	  raise ActionController::RoutingError, "Not Found"
  	end 
  	check { can? :read, @issue }
  	@issue
  end

  def create
    Issue.transaction do
      project_id = request.params[:project_id]
      sprint_id = request.params[:sprint_id]
      sprint = nil
      project = Project.find(project_id)

      if sprint_id
        sync_on "sprints/#{sprint_id}/issues"
      else
        sync_on "projects/#{project_id}/issues"
      end

      params = issue_params.merge(project_id: project_id, sprint_id: sprint_id)

      params.delete :id if params[:id] == -1
      params[:state] = 'Open'

      @issue = Issue.create(params)
      Activity.create(user: current_user, action: "created_issue", issue: @issue, project_context: @issue.project)

      if sprint
        sprint.add_issue(@issue)
      else
        project.add_issue(@issue)
      end
    end
  end

  def update
    Issue.transaction do
      if !@issue
        raise ActionController::RoutingError, "Not Found"
      end 
      check { can? :update, @issue }

      iparams = issue_params

      if @issue.update(iparams)
        if @issue.state_previously_changed?
          Activity.create(user: current_user, action: "set_state", issue: @issue, modifier: issue_params["state"], project_context: @issue.project)
        end
        if !iparams.keys.include?("state") || iparams.keys.count > 1
          Activity.create(user: current_user, action: "updated_issue", issue: @issue, project_context: @issue.project)
        end

        if iparams.keys.include? "epic_id"
          old_epic_id = @issue.epic_id_before_last_save

          sync_on "epics/#{iparams["epic_id"]}"
          sync_on "epics/#{iparams["epic_id"]}/issues"
          epic = Epic.find(iparams["epic_id"])
          epic.add_issue(@issue)

          if old_epic_id
            sync_on "epics/#{old_epic_id}"
            sync_on "epics/#{old_epic_id}/issues"
            epic = Epic.find(old_epic_id)
            epic.remove_issue(@issue)
          end
        end

        if iparams.keys.include? "sprint_id"
          old_sprint_id = @issue.sprint_id_before_last_save

          sync_on "epics/#{iparams["sprint_id"]}"
          sync_on "epics/#{iparams["sprint_id"]}/issues"
          sprint = Sprint.find(iparams["sprint_id"])
          sprint.add_issue(@issue)
          
          if old_sprint_id
            sync_on "epics/#{old_sprint_id}"
            sync_on "epics/#{old_sprint_id}/issues"
            sprint = Sprint.find(old_sprint_id)
            sprint.remove_issue(@issue)
          end
        end

        sync_on path
        render json: @issue, status: :ok, location: @project
      else
        render json: @issue.errors, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @issue = Issue.find(params[:id])
    if !@issue
      raise ActionController::RoutingError, "Not Found"
    end 

    @project = @issue.project
    @sprint = @issue.sprint
    @epic = @issue.epic
    check { can? :delete, @issue }
    check { can? :delete_issue, @project }
    check { can? :delete_issue, @sprint } if @sprint

    if @issue.delete
      if @sprint
        @sprint.update(issue_order: remove_from_order(@sprint.issue_order || default_issue_order(@sprint), @issue.id))
      else 
        @project.update(issue_order: remove_from_order(@project.issue_order || default_issue_order(@project), @issue.id))
      end
      if @epic
        @epic.update(issue_order: remove_from_order(@epic.issue_order || default_issue_order(@epic), @issue.id))
      end

      Activity.create(user: current_user, action: "deleted_issue", modifier: "\##{@issue.id} - #{@issue.title}", project: @project, sprint: @sprint, project_context: @project)
      sync_on path
      render json: { result: "success" }, status: :ok, location: @project
    else
      render json: @issue.errors, status: :unprocessable_entity
    end
  end

  def reorder_tasks
    Issue.transaction do
      issue_id = params[:issue_id]
      @issue = Issue.find(issue_id)
      safe_params = params.require(:data).permit(:fromIndex, :toIndex)
      order = @issue.task_order || default_task_order(@issue)
      order_split = order.split(',')
      order_split.insert(safe_params[:toIndex], order_split.delete_at(safe_params[:fromIndex]))

      @issue.update(task_order: order_split.join(','))
      sync_on "issues/#{issue_id}/tasks"
      sync_on "issues/#{issue_id}"
    end
  end

  def transfer
    transfer_params = params.require(:transfer).permit(:projectId1, :sprintId1, :order1, :projectId2, :sprintId2, :order2)
    Issue.transaction do
      project1 = Project.find(transfer_params[:projectId1])
      sprintId1 = transfer_params[:sprintId1]
      if sprintId1
        sprint1 = Sprint.find(sprintId1)
        parent1 = sprint1
        selectors1 << "sprints/#{sprintId1}/issues"
      else
        sprint1 = nil
        parent1 = project1
        selectors1 << "projects/#{project1.id}/issues"
      end
      
      project2 = Project.find(transfer_params[:projectId2])
      sprintId2 = transfer_params[:sprintId2]
      if sprintId2
        sprint2 = Sprint.find(sprintId2)
        parent2 = sprint2
        sync_on "sprints/#{sprintId2}/issues"
        sync_on "sprints/#{sprintId2}/issues/*"
      else
        sprint2 = nil
        parent2 = project2
        sync_on "projects/#{project2.id}/issues"
        sync_on "projects/#{project2.id}/issues/*"
      end

      order1 = transfer_params[:order1]
      order2 = transfer_params[:order2]

      order1.split(',').each do |issue_id|
        issue = Issue.find(issue_id)
        issue.update(project: project1, sprint: sprint1)
        create_transfer_activity_for(issue)
        sync_on "issues/#{issue_id}"
      end
      order2.split(',').each do |issue_id|
        issue = Issue.find(issue_id)
        issue.update(project: project2, sprint: sprint2)
        create_transfer_activity_for(issue)
        sync_on "issues/#{issue_id}"
      end

      parent1.update(issue_order: order1)
      parent2.update(issue_order: order2)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
  	  @project = @issue.project
      @sprint = @issue.sprint
    end

    # Only allow a list of trusted parameters through.
    def issue_params
      params.require(:issue).permit(:title, :description, :estimate, :state)
    end

    def path
      if @sprint 
        return ["issues/#{@issue.id}",
                "sprints/#{@sprint.id}/issues/*"]
      else
        return ["issues/#{@issue.id}",
                "projects/#{@project.id}/issues/*"] 
      end
    end

    def create_transfer_activity_for(issue)
      if issue.sprint.nil? && issue.sprint_id_before_last_save.present?
        Activity.create(user: current_user, action: 'moved_issue_to_product_backlog', issue: issue, sprint_id: issue.sprint_id_before_last_save, project: issue.project, project_context: issue.project)
      elsif issue.sprint_id_before_last_save.nil? && issue.sprint.present?
        Activity.create(user: current_user, action: 'assigned_issue_to_sprint', issue: issue, sprint: issue.sprint, project: issue.project, project_context: issue.project)
      elsif issue.sprint_id_before_last_save != issue.sprint_id
        old_sprint = Sprint.find(issue.sprint_id_before_last_save)
        Activity.create(user: current_user, action: 'moved_issue_between_sprints', issue: issue, sprint: issue.sprint, sprint2: old_sprint, project_context: issue.project)
      end
    end
end

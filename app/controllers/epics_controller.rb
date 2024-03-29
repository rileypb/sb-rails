class EpicsController < ApplicationController
  before_action :set_epic, only: [:show, :edit, :update]


 
  def index
  	@project = Project.find(params[:project_id])
    check { can? :read, @project }
  	epics = @project.epics
    order = (@project.epic_order || '').split(',')
    @epics = []
    order.each do |i|
      this_epic = epics.find(i) rescue nil
      if this_epic
        @epics << this_epic
      end
    end
    epics.each do |e|
      @epics << e if !@epics.include?(e)
    end
  	@epics = @epics.select do |epic|
  	  can? :read, epic
    end 
  end

  def show
  	check { can? :read, @epic }
  end

  def create
    Epic.transaction do
      project_id = request.params[:project_id]
      project = Project.find(project_id)
      check { can? :create_epic, project }

      sync_on "projects/#{project_id}/epics"

      params = epic_params.merge(project_id: project_id)

      @epic = Epic.create!(params)
      Activity.create(user: current_user, action: "created_epic", epic: @epic, project_context: @epic.project)
      sync_on_activities(@epic.project)
      @epic.project.update!(epic_order: append_to_order(@epic.project.epic_order, @epic.id))

      record_action
    end
  end

  def update
    Epic.transaction do
      check { can? :update, @epic }

      if @epic.update(epic_params)
        Activity.create(user: current_user, action: "updated_epic", epic: @epic, project_context: @epic.project)
        sync_on path
        sync_on "epics/#{@epic.id}/issues/*"
        sync_on_activities(@epic.project)

        record_action
        render json: @epic, status: :ok, location: @project
      else
        render json: @epic.errors, status: :unprocessable_entity
      end
    end
  end

  def destroy
    Epic.transaction do
      @epic = Epic.find(params[:id])
      @project = @epic.project
      check { can? :delete, @epic }
      check { can? :delete_epic, @project }

      @epic.issues.each do |issue| 
        issue.update!(epic: nil)
        sync_on "issues/#{issue.id}"
      end

      @epic.delete
      @project.update!(epic_order: remove_from_order(@project.epic_order || default_epic_order(@project), @epic.id))
      Activity.create(user: current_user, action: "deleted_epic", modifier: "\##{@epic.id} - #{@epic.title}", project: @project, project_context: @project)
      sync_on "projects/#{@epic.project_id}/epics"
      sync_on "projects/#{@epic.project_id}/epics/*"

      sync_on_activities(@project)

      record_action
      render json: { result: "success" }, status: :ok, location: @project
    end
  end

  def remove_issue
    Epic.transaction do
      issue_params = params.require(:issue).permit(:id)
      issue_id = issue_params['id']
      epic_id = request.params[:epic_id]

      issue = Issue.find(issue_id)
      @epic = Epic.find(epic_id)
      check { can? :update, @epic }
      check { can? :update, issue }
      _assert(ArgumentError, "issue does not belong to epic") { issue.epic == @epic }

      issue.update!(epic: nil)
      @epic.update!(issue_order: remove_from_order(@epic.issue_order, issue_id))

      Activity.create(user: current_user, action: "removed_issue_from_epic", issue: issue, epic: @epic, project_context: @epic.project)
      sync_on "projects/#{issue.project_id}/issues/#{issue_id}"
      sync_on "projects/#{issue.project_id}/issues/*"
      sync_on "epics/#{epic_id}/issues"
      sync_on "epics/#{epic_id}/issues/*"
      sync_on "issues/#{issue_id}"
      sync_on_activities(@epic.project)

      record_action
    end
  end

  def add_issue
    Epic.transaction do
      add_params = params.require(:data).permit(:issue_id)
      issue_id = add_params[:issue_id]
      epic_id = request.params[:epic_id] 

      issue = Issue.find(issue_id)
      @epic = Epic.find(epic_id)
      check { can? :update, @epic }
      check { can? :update, issue }
      _assert(ArgumentError, "issue already belongs to epic") { issue.epic != @epic }

      original_epic = issue.epic
      issue.update!(epic: @epic)
      if original_epic
        check { can? :update, original_epic }
        original_epic.update!(issue_order: remove_from_order(original_epic.issue_order, issue_id))
      end
      @epic.update!(issue_order: append_to_order(@epic.issue_order, issue_id))

      if !original_epic
        Activity.create(user: current_user, action: "added_issue_to_epic", issue: issue, epic: @epic, project_context: @epic.project)
      else
        Activity.create(user: current_user, action: "moved_issue_between_epics", issue: issue, epic: original_epic, epic2: @epic, project_context: @epic.project)
      end

      sync_on "issues/#{issue_id}"
      sync_on "projects/#{issue.project.id}/issues/*"
      sync_on "sprints/#{issue.sprint_id}/issues/*" if issue.sprint_id

      sync_on "epics/#{epic_id}"
      sync_on "epics/#{epic_id}/issues"

      if original_epic
        sync_on "epics/#{original_epic.id}"
        sync_on "epics/#{original_epic.id}/issues"
      end
        
      sync_on_activities(@epic.project)

      record_action
    end
  end

  def reorder_issues
    Epic.transaction do
      epic_id = params[:epic_id]
      @epic = Epic.find(epic_id)
      check { can? :update, @epic }
      safe_params = params.require(:data).permit(:fromIndex, :toIndex)
      order = @epic.issue_order
      order = default_issue_order(@epic) unless order.present?
      order_split = order.split(',')
      order_split.insert(Integer(safe_params[:toIndex]), order_split.delete_at(Integer(safe_params[:fromIndex])))

      @epic.update(issue_order: order_split.join(','))
      sync_on "epics/#{epic_id}/issues"
      sync_on "epics/#{epic_id}"

      Activity.create(user: current_user, action: "reordered_issues_within_epic", epic: @epic, project_context: @epic.project)

      sync_on_activities(@epic.project)

      record_action
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_epic
      @epic = Epic.find(params[:id])
  	  @project = @epic.project
    end

    # Only allow a list of trusted parameters through.
    def epic_params
      params.require(:epic).permit(:project_id, :title, :description, :size, :color)
    end

    def path
      return ["epics/#{@epic.id}",
              "projects/#{@epic.project_id}/epics",
              "projects/#{@epic.project_id}/epics/*"] 
    end
end

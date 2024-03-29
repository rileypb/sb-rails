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

    check { can? :read, @parent }

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
      @issues << i if !@issues.include?(i) && !i.completed
    end
    if params[:backlog] == 'true'
      @issues = @issues.select do |issue|
        !issue.sprint
      end
    end
    @issues = @issues.select do |issue|
      can? :read, issue
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

      params = issue_params.merge(project_id: project_id, sprint_id: sprint_id)
      epic_id = params["add_to_epic"]
      params.delete :add_to_epic

      sprint = nil
      project = Project.find(project_id)
      check { can? :create_issue, project }

      if sprint_id
        sync_on "sprints/#{sprint_id}/issues"
      else
        sync_on "projects/#{project_id}/issues"
      end

      params.delete :id if params[:id] == -1
      params[:state] = 'Open'

      @issue = Issue.create(params)
      Activity.create(user: current_user, action: "created_issue", issue: @issue, project_context: @issue.project)

      if sprint
        check { can? :update, sprint }
        sprint.add_issue(@issue)
      else
        project.add_issue(@issue)
      end

      if epic_id
        epic = Epic.find(epic_id)
        if epic
          check { can? :update, epic }
          epic.append_issue(@issue) 
          Activity.create(user: current_user, action: "added_issue_to_epic", issue: @issue, epic: epic, project_context: @issue.project)
          sync_on "epics/#{epic_id}"
          sync_on "epics/#{epic_id}/issues"
        end
      end

      project.update_burndown_data!

      sync_on_activities(project)

      record_action
    end
  end

  def update
    Issue.transaction do
      if !@issue
        raise ActionController::RoutingError, "Not Found"
      end 
      _assert(ActionController::BadRequest, "Cannot update completed issue") { !@issue.completed }

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
          check { can? :update, epic }
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
          check { can? :update, sprint }
          sprint.add_issue(@issue)
          
          if old_sprint_id
            sync_on "epics/#{old_sprint_id}"
            sync_on "epics/#{old_sprint_id}/issues"
            old_sprint = Sprint.find(old_sprint_id)
            check { can? :update, old_sprint }
            old_sprint.remove_issue(@issue)
          end
        end

        @project.update_burndown_data!
        if @issue.sprint
          sync_on "sprints/#{@issue.sprint_id}"
        end
        if @issue.epic 
          sync_on "epics/#{@issue.epic_id}/issues/*"
        end

        sync_on path
        sync_on_activities(@issue.project)

        record_action
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

    @issue.tasks.each { |task| task.delete }

    if @issue.delete
      if @sprint
        @sprint.update!(issue_order: remove_from_order(@sprint.issue_order || default_issue_order(@sprint), @issue.id))
      else 
        @project.update!(issue_order: remove_from_order(@project.issue_order || default_issue_order(@project), @issue.id))
      end
      if @epic
        @epic.update!(issue_order: remove_from_order(@epic.issue_order || default_issue_order(@epic), @issue.id))
      end

      Activity.create(user: current_user, action: "deleted_issue", modifier: "\##{@issue.id} - #{@issue.title}", project: @project, sprint: @sprint, project_context: @project)

      @project.update_burndown_data!
      if @issue.sprint
        sync_on "sprints/#{@issue.sprint_id}"
      end
      if @epic 
        sync_on "epics/#{@epic.id}/issues"
      end

      if @sprint 
        sync_on "sprints/#{@sprint.id}/issues/*"
      else
        sync_on "projects/#{@project.id}/issues/*"
      end

      sync_on_activities(@project)

      record_action
      render json: { result: "success" }, status: :ok, location: @project
    else
      render json: @issue.errors, status: :unprocessable_entity
    end
  end

  def reorder_tasks
    Issue.transaction do
      issue_id = params[:issue_id]
      @issue = Issue.find(issue_id)
      check { can? :update, @issue }
      safe_params = params.require(:data).permit(:fromIndex, :toIndex)
      order = @issue.task_order || default_task_order(@issue)
      order_split = order.split(',')
      order_split.insert(safe_params[:toIndex], order_split.delete_at(safe_params[:fromIndex]))

      @issue.update(task_order: order_split.join(','))

      Activity.create(user: current_user, action: "reordered_tasks", issue: @issue, project_context: @issue.project)

      sync_on "issues/#{issue_id}/tasks"
      sync_on "issues/#{issue_id}"
      sync_on_activities(@issue.project)

      record_action
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
        sync_on "sprints/#{sprintId1}"
        sync_on "sprints/#{sprintId1}/issues"
        sync_on "sprints/#{sprintId1}/issues/*"
      else
        sprint1 = nil
        parent1 = project1
        sync_on "projects/#{project1.id}/issues"
        sync_on "projects/#{project1.id}/issues/*"
      end
      
      project2 = Project.find(transfer_params[:projectId2])
      sprintId2 = transfer_params[:sprintId2]
      if sprintId2
        sprint2 = Sprint.find(sprintId2)
        parent2 = sprint2
        sync_on "sprints/#{sprintId2}"
        sync_on "sprints/#{sprintId2}/issues"
        sync_on "sprints/#{sprintId2}/issues/*"
      else
        sprint2 = nil
        parent2 = project2
        sync_on "projects/#{project2.id}/issues"
        sync_on "projects/#{project2.id}/issues/*"
      end

      sync_on_activities(project1)
      if project1 != project2
        sync_on_activities(project2)
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

      project1.update_burndown_data!
      if project2 != project1
        project2.update_burndown_data!
      end

      check { can? :update, parent1 }
      check { can? :update, parent2 }
      parent1.update(issue_order: order1)
      parent2.update(issue_order: order2)

      record_action
    end
  end

  def assign_issue
    Issue.transaction do
      issue_id = params[:issue_id]
      @issue = Issue.find(issue_id)
      check { can? :update, @issue }
      aparams = params.require(:data).permit(:userId)
      user_id = aparams[:userId]
      user = user_id == -1 ? nil : User.find(user_id)
      @issue.update!(assignee: user)
      sync_on "issues/#{issue_id}"

      if user
        Activity.create(user: current_user, action: "assigned_issue", issue: @issue, project_context: @issue.project, user2: user)
      else
        Activity.create(user: current_user, action: "unassigned_issue", issue: @issue, project_context: @issue.project)
      end
      
      sync_on_activities(@issue.project)

      record_action
    end
  end

  def mark_complete
    Issue.transaction do
      issue_id = params[:issue_id]
      @issue = Issue.find(issue_id)
      if !@issue.closable
        raise ActionController::BadRequest.new("Sprint is not closable.")
      end

      project = @issue.project
      sprint = @issue.sprint
      if !project.allow_issue_completion_without_sprint
        if !sprint
          raise ActionController::BadRequest.new("cannot complete issue without a sprint.")
        end
        if sprint && !project.current_sprint == sprint.id 
          raise ActionController::BadRequest.new("cannot complete issue if its sprint is not in progress.")
        end
      end
      if !@issue.closable
        raise ActionController::BadRequest.new("sprint is not closable.")
      end

      check { can? :update, @issue }

      if !@issue.sprint
        check { can? :update, project }
        project.update!(issue_order: append_to_order(remove_from_order(project.issue_order, issue_id),issue_id))
      end

      @issue.update!(state: 'Closed', completed: true)

      Activity.create(user: current_user, action: "marked_issue_complete", issue: @issue, project_context: @issue.project)

      sync_on_activities(@issue.project)
      sync_on "issues/#{issue_id}"
      sync_on "projects/#{@issue.project_id}/issues"
      sync_on "sprints/#{@issue.sprint_id}/issues"
      
      @issue.project.update_burndown_data!

      record_action
    end
  end

  def move_to_backlog
    Issue.transaction do
      issue_id = params[:issue_id]
      @issue = Issue.find(issue_id)
      sprint_id = @issue.sprint_id

      _assert(ArgumentError, "Issue must belong to a sprint") { |issue| @issue.sprint }
      check { can? :update, @issue }
      check { can? :update, @issue.sprint }

      @sprint = @issue.sprint
      @project = @issue.project

      @issue.update!(sprint: nil)
      new_order = remove_from_order(@sprint.issue_order, @issue.id)
      @sprint.update!(issue_order: new_order)
      @project.update!(issue_order: append_to_order(@project.issue_order, @issue.id.to_s))

      create_transfer_activity_for(@issue)

      sync_on "issues/#{issue_id}"
      sync_on "sprints/#{sprint_id}/issues"
      sync_on "projects/#{@issue.project_id}/issues"
      sync_on_activities(@issue.project)

      record_action
    end
  end

  def move_to_sprint
    Issue.transaction do
      issue_id = params[:issue_id]
      @issue = Issue.find(issue_id)
      sprint_id = params[:sprint_id]
      @sprint = Sprint.find(sprint_id)

      _assert(ActionController::BadRequest, "Cannot add issue to completed sprint") { !@sprint.completed }
      _assert(ActionController::BadRequest, "Cannot add completed issue to sprint") { !@issue.completed }

      _assert(ArgumentError, "Sprints must differ") { |issue| @issue.sprint != @sprint }
      
      check { can? :update, @issue }
      if @issue.sprint 
        check { can? :update, @issue.sprint }
      end
      check { can? :update, @sprint }

      old_sprint = @issue.sprint
      @project = @issue.project

      @issue.update!(sprint: @sprint)
      if old_sprint
        old_sprint.update!(issue_order: remove_from_order(old_sprint.issue_order, @issue.id))
      else
        @project.update!(issue_order: remove_from_order(@project.issue_order, @issue.id))
      end

      @sprint.update!(issue_order: append_to_order(@sprint.issue_order, @issue.id.to_s))

      create_transfer_activity_for(@issue)

      sync_on "issues/#{issue_id}"
      if old_sprint
        sync_on "sprints/#{old_sprint.id}/issues"
      else
        sync_on "projects/#{@issue.project_id}/issues"
      end
      sync_on "sprints/#{sprint_id}/issues"
      sync_on_activities(@issue.project)

      record_action
    end
  end

  def add_acceptance_criterion
    @issue = Issue.find(params[:issue_id])
    check { can? :update, @issue }
    acparams = params.require(:acceptance_criterion).permit(:criterion)
    raise ActionController::BadRequest.new("criterion missing") unless acparams[:criterion] 
    AcceptanceCriterion.create!(issue: @issue, criterion: acparams[:criterion])

    sync_on "issues/#{@issue.id}"

    record_action
  end

  def remove_acceptance_criterion
    @issue = Issue.find(params[:issue_id])
    check { can? :update, @issue }
    @ac = @issue.acceptance_criteria.find(params[:ac_id])
    @ac.delete

    sync_on "issues/#{@issue.id}"

    record_action
  end

  def set_ac_completed
    @issue = Issue.find(params[:issue_id])
    check { can? :accept_ac, @issue }
    acparams = params.require(:acceptance_criterion).permit(:completed)
    @ac = @issue.acceptance_criteria.find(params[:ac_id])
    @ac.update!(completed: acparams[:completed])

    sync_on "issues/#{@issue.id}"
    if @issue.sprint
      sync_on "sprints/#{@issue.sprint_id}"
    end

    record_action
  end

  def update_ac
    @issue = Issue.find(params[:issue_id])
    check { can? :update, @issue }
    acparams = params.require(:acceptance_criterion).permit(:criterion)
    @ac = @issue.acceptance_criteria.find(params[:ac_id])
    @ac.update!(criterion: acparams[:criterion])

    sync_on "issues/#{@issue.id}"

    record_action
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
      params.require(:issue).permit(:title, :description, :estimate, :state, :add_to_epic)
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

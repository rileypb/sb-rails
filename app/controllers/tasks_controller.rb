class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :destroy]


  def index
    @issue = Issue.find(params[:issue_id])

    check { can? :read, @issue }

    tasks = @issue.tasks
    order = (@issue.task_order || '').split(',')
    @tasks = []
    order.each do |t|
      this_task = tasks.find(t) rescue nil
      if this_task 
        @tasks << this_task
      end
    end
    tasks.each do |t|
      @tasks << t if !@tasks.include?(t) 
    end
    @tasks = @tasks.select do |task|
      can? :read, task
    end
  end

  def show
    if !@task
      raise ActionController::RoutingError, "Not Found"
    end
    check { can? :read, @task }
    @task
  end

  def create
    Task.transaction do
      issue_id = request.params[:issue_id]
      @issue = Issue.find(issue_id)
      sprint_id = @issue.sprint_id
      project_id = @issue.project_id

      if sprint_id
        sync_on "sprints/#{sprint_id}"
        sync_on "sprints/#{sprint_id}/team_summary"
      end
      sync_on "issues/#{issue_id}/tasks"
      sync_on "issues/#{issue_id}"
      

      params = task_params.merge(issue_id: issue_id)

      params.delete :id if params[:id] == -1

      @task = Task.create(params)
      if @task
        Activity.create(user: current_user, action: "created_task", task: @task, project_context: @issue.project)
        Activity.create(user: current_user, action: "added_task", issue: @issue, task: @task, modifier: @task.id.to_s, project_context: @issue.project)
      end

      @issue.add_task(@task)
      sync_on_activities(@issue.project)
    end
  end

  def update
    if !@task
      raise ActionController::RoutingError, "Not Found"
    end
    check { can? :update, @task }

    @task.update!(task_params)
    sync_on path
    if @task.issue.sprint
      sync_on "sprints/#{@task.issue.sprint.id}"
      sync_on "sprints/#{@task.issue.sprint.id}/team_summary"
    end
    sync_on "issues/#{@task.issue.id}/tasks"
    sync_on "issues/#{@task.issue.id}"
    Activity.create(user: current_user, action: "updated_task", task: @task, project_context: @task.issue.project)
    sync_on_activities(@task.issue.project)
    render json: @task, status: :ok, location: @issue
  end

  def destroy
    Task.transaction do
      @task = Task.find(params[:id])
      if !@task
        raise ActionController::RoutingError, "Not Found"
      end

      check { can? :delete, @task }
      check { can? :delete_task, @issue }

      @task.delete
      Activity.create(user: current_user, action: "deleted_task", issue: @issue, modifier: @task.title, project_context: @issue.project)
      sync_on path
      if @task.issue.sprint
        sync_on "sprints/#{@task.issue.sprint.id}"
        sync_on "sprints/#{@task.issue.sprint.id}/team_summary"
      end
      sync_on "issues/#{@task.issue.id}/tasks"
      sync_on "issues/#{@task.issue.id}"
      sync_on_activities(@issue.project)
      render json: { result: "success"}, status: :ok, location: @issue
    end
  end

  def set_complete
    Task.transaction do
      @task = Task.find(params[:task_id])
      if !@task
        raise ActionController::RoutingError, "Not Found"
      end
      @issue = @task.issue

      check { can? :update, @task }

      update_params = {state: params[:complete] ? "complete" : "incomplete"}
      if (params[:complete]) 
        update_params[:completed_at] = Time.now
      end

      @task.update!(update_params)
      if params[:complete]
        Activity.create(user: current_user, action: "set_task_complete", task: @task, project_context: @task.issue.project)
        if @issue.project.setting_auto_close_issues
          incomplete_tasks = Task.where("issue_id = #{@issue.id} AND state <> 'complete'")
          if incomplete_tasks.count == 0
            @issue.update!(state: 'Closed')
            sync_on "issues/#{@issue.id}"
            if (@issue.sprint)
              sync_on "sprints/#{@issue.sprint_id}"
              sync_on "sprints/#{@issue.sprint_id}/issues"
              sync_on "sprints/#{@issue.sprint_id}/issues/*"
            end
            Activity.create(user: current_user, action: "set_state", issue: @issue, modifier: "Closed", project_context: @issue.project)
          end
        end
      else
        Activity.create(user: current_user, action: "set_task_incomplete", task: @task, project_context: @task.issue.project)
      end
      sync_on path
      sync_on_activities(@issue.project)
      render json: { result: "success"}, status: :ok, location: @task
    end
  end

  def assign_task
    Task.transaction do
      task_id = params[:task_id]
      @task = Task.find(task_id)
      check { can? :update, @task }
      aparams = params.require(:data).permit(:userId)
      user_id = aparams[:userId]
      user = user_id == -1 ? nil : User.find(user_id)
      @task.update!(assignee: user)
      sync_on "tasks/#{task_id}"
      sync_on "issues/#{@task.issue.id}"
      sync_on "issues/#{@task.issue.id}/tasks"
      sync_on "sprints/#{@task.issue.sprint.id}/team_summary" if @task.issue.sprint

      if user
        Activity.create(user: current_user, action: "assigned_task", task: @task, project_context: @task.issue.project, user2: user)
      else
        Activity.create(user: current_user, action: "unassigned_task", task: @task, project_context: @task.issue.project)
      end
      
      sync_on_activities(@task.issue.project)
    end
  end


  private

    def set_task
      @task = Task.find(params[:id])
      @issue = @task.issue
      @project = @issue.project
      @sprint = @issue.sprint
    end

    def task_params
      params.require(:task).permit(:title, :description, :estimate)
    end

    def path
      return ["tasks/#{@task.id}",
              "issues/#{@issue.id}/tasks/*",
              "issues/#{@issue.id}/tasks"]
    end
end

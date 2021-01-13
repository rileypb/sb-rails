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
        sync_on "issues/#{issue_id}/tasks"
        sync_on "issues/#{issue_id}"
      else
        sync_on "issues/#{issue_id}/tasks"
        sync_on "issues/#{issue_id}"
      end

      params = task_params.merge(issue_id: issue_id)

      params.delete :id if params[:id] == -1

      @task = Task.create(params)
      if @task
        Activity.create(user: current_user, action: "created_task", task: @task, project_context: @issue.project)
        Activity.create(user: current_user, action: "added_task", issue: @issue, task: @task, modifier: @task.id.to_s, project_context: @issue.project)
      end

      @issue.add_task(@task)
    end
  end

  def update
    if !@task
      raise ActionController::RoutingError, "Not Found"
    end
    check { can? :update, @task }

    if @task.update(task_params)
      sync_on path
      render json: @task, status: :ok, location: @issue
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def destroy
    Task.transaction do
      @task = Task.find(params[:id])
      if !@task
        raise ActionController::RoutingError, "Not Found"
      end

      check { can? :delete, @task }
      check { can? :delete_task, @issue }

      if @task.delete
        Activity.create(user: current_user, action: "deleted_task", issue: @issue, modifier: @task.title, project_context: @issue.project)
        sync_on path
        render json: { result: "success"}, status: :ok, location: @issue
      else
        render json: @task.errors, status: :unprocessable_entity
      end
    end
  end

  def set_complete
    Task.transaction do
      @task = Task.find(params[:task_id])
      @issue = @task.issue
      if !@task
        raise ActionController::RoutingError, "Not Found"
      end
      @issue = @task.issue

      check { can? :update, @task }

      if @task.update(state: params[:complete] ? "complete" : "incomplete")
        if params[:complete]
          Activity.create(user: current_user, action: "set_task_complete", task: @task, project_context: @task.issue.project)
        else
          Activity.create(user: current_user, action: "set_task_incomplete", task: @task, project_context: @task.issue.project)
        end
        sync_on path
        render json: { result: "success"}, status: :ok, location: @task
      else
        render json: @task.errors, status: :unprocessable_entity
      end
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

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]


  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.select do |project|
      can? :read, project
    end 
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    check { can? :read, @project }
  end

  # POST /projects
  # POST /projects.json
  def create
    check { can? :create, Project }
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    check { can? :update, @project }

    Project.transaction do
      params = project_params

      respond_to do |format|
        if @project.update(params)
          Activity.create(user: current_user, action: "updated_project", project: @project, project_context: @project)
          format.json { render :show, status: :ok, location: @project }
          sync_on "projects/#{@project.id}"
          sync_on_activities(@project)
        else
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def reorder_epics
    Project.transaction do
      project_id = params[:project_id]
      @project = Project.find(project_id)
      safe_params = params.require(:data).permit(:fromIndex, :toIndex)
      order = @project.epic_order || default_epic_order(@project)
      order_split = order.split(',')
      order_split.insert(Integer(safe_params[:toIndex]), order_split.delete_at(Integer(safe_params[:fromIndex])))

      @project.update(epic_order: order_split.join(','))

      Activity.create(user: current_user, action: "reordered_epics", project: @project, project_context: @project)

      sync_on "projects/#{project_id}/epics"
      sync_on "projects/#{project_id}"
      sync_on_activities(@project)
    end
  end

  def reorder_issues
    Project.transaction do
      project_id = params[:project_id]
      @project = Project.find(project_id)
      safe_params = params.require(:data).permit(:fromIndex, :toIndex)
      order = @project.issue_order || default_issue_order(@project)
      order_split = order.split(',')
      order_split.insert(Integer(safe_params[:toIndex]), order_split.delete_at(Integer(safe_params[:fromIndex])))

      Activity.create(user: current_user, action: "reordered_issues", project: @project, project_context: @project)

      @project.update(issue_order: order_split.join(','))
      sync_on "projects/#{project_id}/issues"
      sync_on "projects/#{project_id}"
      sync_on_activities(@project)
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    check { can? :delete, @project }
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def activity
    @project = Project.find(params[:project_id])
    check { can? :read, @project }
  end

  def team
    @project = Project.find(params[:project_id])
    check { can? :read, @project }
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :owner_id)
    end
end

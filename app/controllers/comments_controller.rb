class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
    @project = params[:project_id] ? Project.find(params[:project_id]) : nil
    @epic = params[:epic_id] ? Epic.find(params[:epic_id]) : nil
    @issue = params[:issue_id] ? Issue.find(params[:issue_id]) : nil
    @sprint = params[:sprint_id] ? Sprint.find(params[:sprint_id]) : nil

    if @project
      @comments = Comment.all.where("project_id = #{@project.id}")
    elsif @epic
      @comments = Comment.all.where("epic_id = #{@epic.id}")
    elsif @issue
      @comments = Comment.all.where("issue_id = #{@issue.id}")
    elsif @sprint
      @comments = Comment.all.where("sprint_id = #{@sprint.id}")
    else
      @comments = Comment.all
    end

  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @comment 
  end

  # POST /comments
  # POST /comments.json
  def create
    Comment.transaction do
      @comment = Comment.new(comment_params)
      @comment.user = current_user

      @project = params[:project_id] ? Project.find(params[:project_id]) : nil
      @epic = params[:epic_id] ? Epic.find(params[:epic_id]) : nil
      @issue = params[:issue_id] ? Issue.find(params[:issue_id]) : nil
      @sprint = params[:sprint_id] ? Sprint.find(params[:sprint_id]) : nil

      if @project
        @comment.project = @project
        @comment.project_context = @project
        sync_on "projects/#{@project.id}"
      elsif @epic
        @comment.epic = @epic
        @comment.project_context = @epic.project
        sync_on "epics/#{@epic.id}"
      elsif @issue
        @comment.issue = @issue
        @comment.project_context = @issue.project
        sync_on "issues/#{@issue.id}"
      elsif @sprint
        @comment.sprint = @sprint
        @comment.project_context = @sprint.project
        sync_on "sprints/#{@sprint.id}"
      else
        raise ActionController::BadRequest
      end

      @comment.save!

      project = @comment.project_context
      team = project.team_members
      team.each do |member|
        if member != current_user
          NewsItem.create!(user: member, seen: false, comment: @comment)
        end
      end
      sync_on "news"

    end
  end

  # # PATCH/PUT /comments/1
  # # PATCH/PUT /comments/1.json
  # def update
  #   respond_to do |format|
  #     if @comment.update(comment_params)
  #       format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @comment }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @comment.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /comments/1
  # # DELETE /comments/1.json
  # def destroy
  #   @comment.destroy
  #   respond_to do |format|
  #     format.html { redirect_to comments_url, notice: 'Comment was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:comment).permit(:text)
    end
end

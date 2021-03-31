require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:admin)
    set_token_for(@user)
  end

  test "should get index for project" do
    project1 = create(:project)
    project2 = create(:project)
    comment1 = create(:comment, project: project1, project_context: project1)
    comment2 = create(:comment, project_context: project1)
    comment3 = create(:comment, project: project2, project_context: project2)

    get project_comments_url(project_id: project1.id), 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.length
    assert_equal comment1.id, json[0]["id"]
  end

  test "should get index for epic" do
    project1 = create(:project)
    epic1 = create(:epic, project: project1)
    epic2 = create(:epic, project: project1)
    comment1 = create(:comment, epic: epic1, project_context: project1)
    comment2 = create(:comment, epic: epic2, project_context: project1)

    get epic_comments_url(epic_id: epic1.id), 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.length
    assert_equal comment1.id, json[0]["id"]
  end

  test "should get index for issue" do
    project1 = create(:project)
    issue1 = create(:issue, project: project1)
    issue2 = create(:issue, project: project1)
    comment1 = create(:comment, issue: issue1, project_context: project1)
    comment2 = create(:comment, issue: issue2, project_context: project1)

    get issue_comments_url(issue_id: issue1.id), 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.length
    assert_equal comment1.id, json[0]["id"]
  end

  test "should get index for sprint" do
    project1 = create(:project)
    sprint1 = create(:sprint, project: project1)
    sprint2 = create(:sprint, project: project1)
    comment1 = create(:comment, sprint: sprint1, project_context: project1)
    comment2 = create(:comment, sprint: sprint2, project_context: project1)

    get sprint_comments_url(sprint_id: sprint1.id), 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json.length
    assert_equal comment1.id, json[0]["id"]
  end

  test "should get index for all" do
    comment1 = create(:comment)
    comment2 = create(:comment)

    get comments_url, 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 2, json.length
  end

  test "should create project comment" do
    project = create(:project)
    comment_text = "this is some test text."
    assert_difference('Comment.count') do
      post project_comments_url(project_id: project.id), params: { comment: { text: comment_text } }, 
        headers: { 'Authorization': "Bearer #{token}"}
      assert_response :success
    end

    new_comment = Comment.last
    assert_equal @user, new_comment.user
    assert_equal new_comment.text, comment_text
    assert_equal project, new_comment.project
    assert_equal project, new_comment.project_context
  end

  test "should create epic comment" do
    project = create(:project)
    epic = create(:epic, project: project)
    comment_text = "this is some test text."
    assert_difference('Comment.count') do
      post epic_comments_url(epic_id: epic.id), params: { comment: { text: comment_text } }, 
        headers: { 'Authorization': "Bearer #{token}"}
      assert_response :success
    end

    new_comment = Comment.last
    assert_equal @user, new_comment.user
    assert_equal new_comment.text, comment_text
    assert_equal epic, new_comment.epic
    assert_equal project, new_comment.project_context
  end

  test "should create issue comment" do
    project = create(:project)
    issue = create(:issue, project: project)
    comment_text = "this is some test text."
    assert_difference('Comment.count') do
      post issue_comments_url(issue_id: issue.id), params: { comment: { text: comment_text } }, 
        headers: { 'Authorization': "Bearer #{token}"}
      assert_response :success
    end

    new_comment = Comment.last
    assert_equal @user, new_comment.user
    assert_equal new_comment.text, comment_text
    assert_equal issue, new_comment.issue
    assert_equal project, new_comment.project_context
  end

  test "should create sprint comment" do
    project = create(:project)
    sprint = create(:sprint, project: project)
    comment_text = "this is some test text."
    assert_difference('Comment.count') do
      post sprint_comments_url(sprint_id: sprint.id), params: { comment: { text: comment_text } }, 
        headers: { 'Authorization': "Bearer #{token}"}
      assert_response :success
    end

    new_comment = Comment.last
    assert_equal @user, new_comment.user
    assert_equal new_comment.text, comment_text
    assert_equal sprint, new_comment.sprint
    assert_equal project, new_comment.project_context
  end

  test "should error on create unowned comment" do
    comment_text = "this is some test text."
    assert_no_difference('Comment.count') do
      post comments_url, params: { comment: { text: comment_text } }, 
        headers: { 'Authorization': "Bearer #{token}"}
      assert_response :bad_request
    end
  end

  test "should show comment" do
    comment = create(:comment)
    get comment_url(comment), 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal comment.id, json["id"]
    assert_equal comment.text, json["text"]
  end

  # test "should update comment" do
  #   patch comment_url(@comment), params: { comment: { epic_id: @comment.epic_id, issue_id: @comment.issue_id, project_id: @comment.project_id, sprint_id: @comment.sprint_id, text: @comment.text, user_id: @comment.user_id } }
  #   assert_redirected_to comment_url(@comment)
  # end

  # test "should destroy comment" do
  #   assert_difference('Comment.count', -1) do
  #     delete comment_url(@comment)
  #   end

  #   assert_redirected_to comments_url
  # end
end

require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:owned_by_admin)

    # get '/users/sign_in'
    # sign_in users(:admin)
    # post user_session_url

    set_token_for(create(:admin))
  end


  test "should get index" do
    get projects_url, 
      headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success
  end


  test "should create project" do
    assert_difference('Project.count', 1) do
      post projects_url, params: { project: { name: 'test project', owner_id: users(:admin).id } }, 
        headers: { 'Authorization': "Bearer #{token}"}
    end

    new_project = Project.last
    assert_equal 'test project', new_project.name
    assert_equal users(:admin).id, new_project.owner_id

    assert_response :created
  end

  test "should show project" do
    get project_url(@project), 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success
  end


  test "should update project" do
    patch project_url(@project), params: { project: { name: 'foo' } }, 
      headers: { 'Authorization': "Bearer #{token}"}
    @project.reload
    assert_equal 'foo', @project.name
    assert_response :success
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete project_url(@project), 
      headers: { 'Authorization': "Bearer #{token}"}
    end

    assert_response :no_content
  end

  test "reorder issues" do
    project = create(:project)
    issue1 = create(:issue, project: project)
    issue2 = create(:issue, project: project)
    issue3 = create(:issue, project: project)
    project.update(issue_order: "#{issue3.id},#{issue2.id},#{issue1.id}")
    project.reload

    patch project_reorder_issues_url(project), params: { data: { fromIndex: 0, toIndex: 2 }}, 
      headers: { 'Authorization': "Bearer #{token}"}

    project.reload
    assert_response :no_content
    assert_equal "#{issue2.id},#{issue1.id},#{issue3.id}", project.issue_order
  end

  test "reorder issues no order" do
    project = create(:project)
    issue1 = create(:issue, project: project)
    issue2 = create(:issue, project: project)
    issue3 = create(:issue, project: project)

    patch project_reorder_issues_url(project), params: { data: { fromIndex: 0, toIndex: 2 }}, 
      headers: { 'Authorization': "Bearer #{token}"}

    project.reload
    assert_response :no_content
    assert_equal "#{issue2.id},#{issue3.id},#{issue1.id}", project.issue_order
  end

  test "reorder epics" do
    epic1 = create(:epic, project: @project)
    epic2 = create(:epic, project: @project)
    epic3 = create(:epic, project: @project)
    @project.update(epic_order: "#{epic2.id},#{epic1.id},#{epic3.id}")
    @project.reload

    patch project_reorder_epics_url(@project), params: { data: { fromIndex: 0, toIndex: 2 }}, 
      headers: { 'Authorization': "Bearer #{token}"}

    @project.reload
    assert_response :no_content
    assert_equal "#{epic1.id},#{epic3.id},#{epic2.id}", @project.epic_order
  end

  test "reorder epics no order" do
    epic1 = create(:epic, project: @project)
    epic2 = create(:epic, project: @project)
    epic3 = create(:epic, project: @project)

    patch project_reorder_epics_url(@project), params: { data: { fromIndex: 0, toIndex: 2 }}, 
      headers: { 'Authorization': "Bearer #{token}"}

    @project.reload
    assert_response :no_content
    assert_equal "#{epic2.id},#{epic3.id},#{epic1.id}", @project.epic_order
  end
end

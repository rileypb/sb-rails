require 'test_helper'

class EpicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:owned_by_admin)

    set_token_for(create(:admin))
  end

  test "should get project epics index" do
    epic1 = create(:epic, project: @project)
    epic2 = create(:epic, project: @project)
    epic3 = create(:epic) # different project
  	get project_epics_url(@project), 
        headers: { 'Authorization': "Bearer #{token}"}
  	assert_response :success

    body = JSON.parse(response.body)
    epics_list = body["epics"]["list"]
    assert_equal 2, epics_list.count
  end

  test "project epics index in order" do
    epic1 = create(:epic, project: @project)
    epic2 = create(:epic, project: @project)
    epic3 = create(:epic, project: @project)
    @project.update(epic_order: "#{epic2.id},#{epic3.id},#{epic1.id}")
    get project_epics_url(@project), 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :success

    body = JSON.parse(response.body)
    epics_list = body["epics"]["list"]
    assert_equal 3, epics_list.count
    assert_equal epic2.id, epics_list[0]["id"]
    assert_equal epic3.id, epics_list[1]["id"]
    assert_equal epic1.id, epics_list[2]["id"]
  end

  test "should show epic" do
  	epic = create(:epic, size: 2, color: '#FF00FF')
  	get epic_url(epic.id), 
        headers: { 'Authorization': "Bearer #{token}"}
  	assert_response :success

  	json_body = JSON.parse(response.body)
  	assert_equal epic.title, json_body["title"]
  	assert_equal epic.description, json_body["description"]
  	assert_equal epic.size, json_body["size"]
  	assert_equal epic.project_id, json_body["project"]["id"]
  	assert_equal epic.color, json_body["color"]
  end

  test "don't show unknown epic" do
    epic = create(:epic)
    get epic_url(id: 1), 
        headers: { 'Authorization': "Bearer #{token}"}
    assert_response :not_found
  end

  test "should create epic" do
  	project = create(:project)
    assert_difference('Epic.count', 1) do
  		post project_epics_url(project, epic: { title: "my title", description: "my description", size: 3, color: '#FFF' }), 
        headers: { 'Authorization': "Bearer #{token}"}
  	end

  	assert_response :success
  	epic = Epic.last

  	project.reload

  	assert_equal "my title", epic.title
  	assert_equal "my description", epic.description
  	assert_equal 3, epic.size
  	assert_equal '#FFF', epic.color

  	assert_equal project, epic.project
  	assert_equal "#{epic.id}", project.epic_order
  end

  test "should create epic appends to order" do
  	project = create(:project)
  	project.update(epic_order: "1,2,3")
  	project.reload
    assert_difference('Epic.count', 1) do
  		post project_epics_url(project, epic: { title: "my title", description: "my description", size: 3, color: '#FFF' }), 
        headers: { 'Authorization': "Bearer #{token}"}
  	end

  	assert_response :success
  	epic = Epic.last

  	project.reload

  	assert_equal "my title", epic.title
  	assert_equal "my description", epic.description
  	assert_equal 3, epic.size
  	assert_equal '#FFF', epic.color

  	assert_equal project, epic.project
  	assert_equal "1,2,3,#{epic.id}", project.epic_order
  end

  test "should update epic" do
  	epic = create(:epic, title: "my title", description: "my description", size: 3, color: '#FFF')

  	patch epic_url(epic, epic: { title: "new title", description: "new description", size: 5, color: '#444' }), 
        headers: { 'Authorization': "Bearer #{token}"}
  	assert_response :success

  	epic.reload
  	assert_equal "new title", epic.title
  	assert_equal "new description", epic.description
  	assert_equal 5, epic.size
  	assert_equal '#444', epic.color
  end

  test "should update epic error" do
  end

  test "should destroy epic" do
  	epic = create(:epic)
  	project = epic.project
  	project.update(epic_order: "#{epic.id},2,3")

    assert_difference('Epic.count', -1) do
    	delete epic_url(epic), 
        headers: { 'Authorization': "Bearer #{token}"}
    end

    project.reload
    assert_equal "2,3", project.epic_order
  end

  test "destroy epic with issues" do
    epic = create(:epic)
    project = epic.project
    issue = create(:issue, project: project, epic: epic)
    assert_equal epic, issue.epic

    assert_difference('Epic.count', -1) do
      delete epic_url(epic), 
        headers: { 'Authorization': "Bearer #{token}"}
    end

    issue.reload
    assert_nil issue.epic
  end

  test "remove_issue" do
  	project = create(:project)
  	epic = create(:epic, project: project)
  	issue = create(:issue, epic: epic, project: project)
  	epic.update(issue_order: "1,#{issue.id},2")

  	epic.reload

  	patch epic_remove_issue_url(epic, issue: { id: issue.id }), 
        headers: { 'Authorization': "Bearer #{token}"}

  	epic.reload
  	issue.reload

  	assert_equal 0, epic.issues.count
  	assert_equal "1,2", epic.issue_order
  	assert_nil issue.epic
  end

  test "add_issue" do
  	project = create(:project)
  	epic = create(:epic, project: project)
  	issue = create(:issue, project: project)
  	epic.update(issue_order: "1,2")

  	epic.reload

  	patch epic_add_issue_url(epic, data: { issue_id: issue.id }), 
        headers: { 'Authorization': "Bearer #{token}"}

  	epic.reload
  	issue.reload

  	assert_equal 1, epic.issues.count
  	assert_equal "1,2,#{issue.id}", epic.issue_order
  	assert_equal epic, issue.epic
  end

  test "add_issue that already belongs to an epic" do
    project = create(:project)
    epic = create(:epic, project: project)
    epic2 = create(:epic, project: project)
    issue = create(:issue, project: project, epic: epic2)

    epic.reload

    patch epic_add_issue_url(epic, data: { issue_id: issue.id }), 
        headers: { 'Authorization': "Bearer #{token}"}

    epic.reload
    epic2.reload
    issue.reload

    assert_equal 1, epic.issues.count
    assert_equal epic, issue.epic
    assert_equal "#{issue.id}", epic.issue_order
    assert_equal "", epic2.issue_order
    assert_equal 0, epic2.issues.count
  end

  test "reorder_issues" do
  	epic = create(:epic, issue_order: "1,2,3,4")
  	patch epic_reorder_issues_url(epic, data: { fromIndex: 3, toIndex: 1 }), 
        headers: { 'Authorization': "Bearer #{token}"}
  	epic.reload
  	assert_equal "1,4,2,3", epic.issue_order
  end

  test "reorder_issues no order" do
  	epic = create(:epic)
  	issue1 = create(:issue, epic: epic)
  	issue2 = create(:issue, epic: epic)
  	issue3 = create(:issue, epic: epic)
  	assert_equal "", epic.issue_order

  	patch epic_reorder_issues_url(epic, data: { fromIndex: 2, toIndex: 1 }), 
        headers: { 'Authorization': "Bearer #{token}"}
  	epic.reload
  	assert_equal "#{issue1.id},#{issue3.id},#{issue2.id}", epic.issue_order
  end
end
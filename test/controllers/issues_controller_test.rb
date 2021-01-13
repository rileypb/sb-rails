require 'test_helper'

class IssuesControllerTest < ActionDispatch::IntegrationTest

  def admin
  	if !@admin 
  	  @admin = create(:admin)
  	end
  	return @admin
  end

  ### IssuesController.index ###

  test "project index for admin lists all issues" do
  	login(admin)
  	issue1 = create(:issue)
    project = issue1.project
    issue2 = create(:issue, project: project)
    sprint = create(:sprint, project: project)
    issue3 = create(:issue, project: project, sprint: sprint)

    get project_issues_url project_id: project.id
    assert_response :ok
    body_s = response.body
    body = JSON.load(body_s)
    issues = body["issues"]
    issues_list = issues["list"]
    assert_equal 3, issues_list.length
  end

  test "sprint index for admin lists all issues" do
    login(admin)
    issue1 = create(:issue)
    project = issue1.project
    issue2 = create(:issue, project: project)
    sprint = create(:sprint, project: project)
    issue3 = create(:issue, project: project, sprint: sprint)

    get sprint_issues_url sprint_id: sprint.id
    assert_response :ok
    body_s = response.body
    body = JSON.load(body_s)
    issues = body["issues"]
    issues_list = issues["list"]
    assert_equal 1, issues_list.length
  end

  test "epic index for admin lists all issues" do
    login(admin)
    issue1 = create(:issue)
    project = issue1.project
    issue2 = create(:issue, project: project)
    epic = create(:epic, project: project)
    issue3 = create(:issue, project: project, epic: epic)

    get epic_issues_url epic_id: epic.id
    assert_response :ok
    body_s = response.body
    body = JSON.load(body_s)
    issues = body["issues"]
    issues_list = issues["list"]
    assert_equal 1, issues_list.length
  end

  test "index returns 404 when project not found" do
    login(admin)
    issue1 = create(:issue)
    project = issue1.project
    issue2 = create(:issue, project: project)

    get project_issues_url project_id: project.id + 1
    assert_response :not_found
  end

  test "index returns 404 when sprint not found" do
    login(admin)
    issue1 = create(:issue)
    project = issue1.project
    issue2 = create(:issue, project: project)
    sprint = create(:sprint, project: project)
    issue3 = create(:issue, project: project, sprint: sprint)

    get sprint_issues_url sprint_id: sprint.id + 1
    assert_response :not_found
  end

  test "index returns 404 when no permissions" do
    login(create(:user))
    issue1 = create(:issue)
    project = issue1.project
    issue2 = create(:issue, project: project)

    get project_issues_url project_id: project.id
    assert_response :not_found
  end

  test "index returns issues in order" do
    login(admin)
    issue1 = create(:issue)
    project = issue1.project
    issue2 = create(:issue, project: project)
    issue3 = create(:issue, project: project)

    order = "#{issue2.id},#{issue3.id},#{issue1.id}"
    project.update(issue_order: order)

    get project_issues_url project_id: project.id
    assert_response :ok
    body_s = response.body
    body = JSON.load(body_s)
    issues = body["issues"]
    issues_list = issues["list"]
    assert_equal 3, issues_list.length

    assert_equal issue2.id, issues_list[0]["id"]
    assert_equal issue3.id, issues_list[1]["id"]
    assert_equal issue1.id, issues_list[2]["id"]
  end


  ### IssuesController.show ###

  ### IssuesController.destroy ###

  # when deleting a product backlog issue, must update the project's issue_order
  test "deleting PBI updates project's issue order" do
    login(admin)
    issue1 = create(:issue)
    issue2 = create(:issue, project: issue1.project)
    issue3 = create(:issue, project: issue1.project)
    project = issue1.project
    project.update(issue_order: "#{issue1.id},#{issue2.id},#{issue3.id}")
    project.reload

    delete issue_url id: issue2.id

    project.reload
    assert_equal "#{issue1.id},#{issue3.id}", project.issue_order
  end 

  test "deleting PBI updates project's issue order when order is nil" do
    login(admin)
    issue1 = create(:issue)
    issue2 = create(:issue, project: issue1.project)
    issue3 = create(:issue, project: issue1.project)
    project = issue1.project

    delete issue_url id: issue2.id

    project.reload
    assert_equal "#{issue1.id},#{issue3.id}", project.issue_order
  end 

  # when deleting a sprint backlog issue, must update the sprint's issue_order
  test "deleting SBI updates sprint's issue order" do
    login(admin)
    project = create(:project)
    sprint = create(:sprint, project: project)
    issue1 = create(:issue, project: project, sprint: sprint)
    issue2 = create(:issue, project: project, sprint: sprint)
    issue3 = create(:issue, project: project, sprint: sprint)
    sprint.update(issue_order: "#{issue1.id},#{issue2.id},#{issue3.id}")
    sprint.reload

    delete issue_url id: issue2.id

    sprint.reload
    assert_equal "#{issue1.id},#{issue3.id}", sprint.issue_order
  end 

  # when deleting a sprint backlog issue, must update the sprint's issue_order
  test "deleting SBI updates sprint's issue order when order is nil" do
    login(admin)
    project = create(:project)
    sprint = create(:sprint, project: project)
    issue1 = create(:issue, project: project, sprint: sprint)
    issue2 = create(:issue, project: project, sprint: sprint)
    issue3 = create(:issue, project: project, sprint: sprint)
    sprint.reload

    delete issue_url id: issue2.id

    sprint.reload
    assert_equal "#{issue1.id},#{issue3.id}", sprint.issue_order
  end 


  # when deleting an epic issue, must update the epic's issue_order
  test "deleting epic issue updates epic's issue order" do
    login(admin)
    project = create(:project)
    epic = create(:epic, project: project)
    issue1 = create(:issue, project: project, epic: epic)
    issue2 = create(:issue, project: project, epic: epic)
    issue3 = create(:issue, project: project, epic: epic)
    epic.update(issue_order: "#{issue1.id},#{issue2.id},#{issue3.id}")
    epic.reload

    delete issue_url id: issue2.id

    epic.reload
    assert_equal "#{issue1.id},#{issue3.id}", epic.issue_order
  end 

  # when deleting an epic issue, must update the epic's issue_order
  test "deleting epic issue updates epic's issue order when order nil" do
    login(admin)
    project = create(:project)
    epic = create(:epic, project: project)
    issue1 = create(:issue, project: project, epic: epic)
    issue2 = create(:issue, project: project, epic: epic)
    issue3 = create(:issue, project: project, epic: epic)
    epic.update(issue_order: nil)
    epic.reload

    delete issue_url id: issue2.id

    epic.reload
    assert_equal "#{issue1.id},#{issue3.id}", epic.issue_order
  end 

  test "fetch all issues" do
    login(admin)
    project1 = create(:project)
    project2 = create(:project)
    issue1 = create(:issue, project: project1)
    issue2 = create(:issue, project: project1)
    issue3 = create(:issue, project: project1)
    issue4 = create(:issue, project: project2)
    issue5 = create(:issue, project: project2)
    issue6 = create(:issue, project: project2)

    get project_all_issues_url project_id: project1.id

    assert_response :ok
    body_s = response.body
    body = JSON.load(body_s)
    assert 3, body["issues"]["list"].count

    ids = body["issues"]["list"].map { |x| x["id"] }
    assert ids.include? issue1.id
    assert ids.include? issue2.id
    assert ids.include? issue3.id
  end


end

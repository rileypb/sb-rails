require 'test_helper'

class SprintControllerTest < ActionDispatch::IntegrationTest
  def admin
  	if !@admin 
  	  @admin = create(:admin)
  	end
  	return @admin
  end

  test "index for admin" do
  	login(admin)
    sprint1 = create(:sprint)
    sprint2 = create(:sprint, project: sprint1.project)
    project = sprint1.project

    get project_sprints_url project_id: sprint1.project.id
    assert_response :ok

    body = JSON.parse(response.body)
    sprints = body["sprints"]
    list = sprints["list"]
    assert_equal 2, list.count
    
    assert_equal sprint1.id, list[0]["id"]
    assert_equal sprint2.id, list[1]["id"]
    assert_equal sprint1.title, list[0]["title"]
    assert_equal sprint2.title, list[1]["title"]
    assert_equal ["read", "update", "delete", "create-issue", "delete-issue"], list[0]["permissions"]
    assert_equal ["read", "update", "delete", "create-issue", "delete-issue"], list[1]["permissions"]
    project0 = list[0]["project"]
    assert_equal project.id, project0["id"]
    assert_equal project.name, project0["name"]
    project1 = list[1]["project"]
    assert_equal project.id, project1["id"]
    assert_equal project.name, project1["name"]

    assert_equal ["read", "update", "delete", "create-issue", "delete-issue", "create-sprint", "delete-sprint", "create-epic", "delete-epic"], project0["permissions"]
    assert_equal ["read", "update", "delete", "create-issue", "delete-issue", "create-sprint", "delete-sprint", "create-epic", "delete-epic"], project1["permissions"]
  end

  test "start_sprint" do
    login(admin)
    sprint = create(:sprint)
    sprint2 = create(:sprint, project: sprint.project)
    sprint3 = create(:sprint)
    assert_nil sprint.project.current_sprint
    assert_nil sprint3.project.current_sprint

    post sprint_start_url sprint_id: sprint.id
    assert_response :ok

    sprint.reload
    assert_equal sprint, sprint.project.current_sprint
    assert_nil sprint3.project.current_sprint
  end

  test "start_sprint_current_sprint_exists" do
    login(admin)
    sprint = create(:sprint)
    sprint2 = create(:sprint, project: sprint.project)
    sprint3 = create(:sprint)
    assert_nil sprint.project.current_sprint
    assert_nil sprint3.project.current_sprint

    sprint2.project.update(current_sprint: sprint2)
    sprint.reload
    sprint2.reload
    sprint3.reload

    post sprint_start_url sprint_id: sprint.id
    assert_response :bad_request

    sprint.reload
    assert_equal sprint2, sprint.project.current_sprint
    assert_nil sprint3.project.current_sprint
  end

end

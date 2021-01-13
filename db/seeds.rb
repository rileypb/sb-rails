def createProject(name, owner)
  issue_list = IssueList.create!(name: "#{name} product backlog")
  project = Project.create!(name: name, owner: owner, issue_list: issue_list)
  project
end

def createSprint(name, project)
  sprint = Sprint.new(title: name, project: project)
  issue_list = IssueList.new(name: "#{name} sprint backlog")
  sprint.backlog = issue_list
  sprint.save!
  sprint
end

def createProductBacklogIssue(title, project)
  issue = Issue.create!(title: title, issue_list: project.issue_list, project: project)
end

User.create!([
  {email: "rileypb@gmail.com", password: "password", password_confirmation: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, provider: "google_oauth2", uid: "100274537645316706670", first_name: "Phil", last_name: "Riley", picture: "https://lh3.googleusercontent.com/a-/AOh14GiTMtC-k_zwqUgPOj-Z6pBWgG19E1VSf7_1kZKiRg", permission_scope: "admin"},
  {email: "utest8720@gmail.com", password: "password", password_confirmation: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, provider: "google_oauth2", uid: "107149567630155958876", first_name: "Test 1", last_name: "User", picture: "https://lh3.googleusercontent.com/a-/AOh14GjVZmlmsnNE5JlLlrua7JWjERo8SyClxsZU29Tm", permission_scope: "member"}
])

project1 = createProject("Project 1", User.first)
project2 = createProject("Project 2", User.second)
project3 = createProject("Project 3", User.first)

createProductBacklogIssue("Issue 1", project1)
createProductBacklogIssue("Issue 2", project1)
createProductBacklogIssue("Issue 3", project1)
createProductBacklogIssue("Issue 4", project1)

ProjectPermission.create!([
  {project_id: 1, user_id: 2, scope: "read"},
  {project_id: 1, user_id: 2, scope: "update"}
])

sprint1 = createSprint("Sprint 1", project1)

Project.first.issue_list.update!(order: "4,3,1,2")
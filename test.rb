User.create!([
  {email: "rileypb@gmail.com", encrypted_password: "$2a$12$lVHpyL3FGr9pOP5OU7tin.338QT0D6awMquHX4/8IJvS99knWJOLC", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, provider: "google_oauth2", uid: "100274537645316706670", first_name: "Phil", last_name: "Riley", picture: "https://lh3.googleusercontent.com/a-/AOh14GiTMtC-k_zwqUgPOj-Z6pBWgG19E1VSf7_1kZKiRg", permission_scope: "admin"},
  {email: "utest8720@gmail.com", encrypted_password: "$2a$12$qSo1J5pmEeJ48uDCCGDJM.g4dIC63VN4av1zxGzmYf4kDJQCXBBbK", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, provider: "google_oauth2", uid: "107149567630155958876", first_name: "Test 1", last_name: "User", picture: "https://lh3.googleusercontent.com/a-/AOh14GjVZmlmsnNE5JlLlrua7JWjERo8SyClxsZU29Tm", permission_scope: "member"}
])
Issue.create!([
  {title: "Write front-end", description: "Make it look nice.", estimate: "8 points", state: "pending", progress: 0, issue_list_id: 1, project_id: 1}
])
IssueList.create!([
  {name: nil, project_id: 1},
  {name: nil, project_id: 2},
  {name: nil, project_id: 1}
])
Project.create!([
  {name: "Project 1", issue_list_id: 1, owner_id: 1},
  {name: "Project 2", issue_list_id: 2, owner_id: 2}
])
ProjectPermission.create!([
  {project_id: 1, user_id: 2, scope: "read"},
  {project_id: 1, user_id: 2, scope: "update"}
])
Sprint.create!([
  {title: "Shark Sandwich", description: nil, project_id: 1, backlog_id: 3}
])

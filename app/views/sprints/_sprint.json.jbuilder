json.extract! sprint, :id, :title, :created_at, :updated_at
json.path project_sprint_path(id: sprint.id, project_id: sprint.project.id, format: :json)
json.permissions sprint.permissions(current_user)
json.project do
  json.id sprint.project.id
  json.name sprint.project.name
  json.permissions sprint.project.permissions(current_user)
end
json.burndownData sprint.burndown_graph

json.extract! sprint, :id, :title, :goal, :started, :completed, :start_date, :end_date, :created_at, :updated_at, :actual_end_date, :retrospective, :description
json.path project_sprint_path(id: sprint.id, project_id: sprint.project.id, format: :json)
json.project do
  json.id sprint.project.id
  json.name sprint.project.name
  json.current_sprint_id sprint.project.current_sprint_id
end
json.permissions sprint.permissions(@current_user)

json.extract! sprint, :id, :title, :goal, :started, :completed, :start_date, :end_date, :created_at, :updated_at, :actual_end_date, :retrospective
json.path project_sprint_path(id: sprint.id, project_id: sprint.project.id, format: :json)
json.project do
  json.id sprint.project.id
  json.name sprint.project.name
end

json.extract! sprint, :id, :title, :goal, :started, :completed, :start_date, :end_date, :created_at, :updated_at, :actual_end_date, :retrospective
json.path project_sprint_path(id: sprint.id, project_id: sprint.project.id, format: :json)
json.permissions sprint.permissions(@current_user)
json.project do
  json.id sprint.project.id
  json.name sprint.project.name
  json.permissions sprint.project.permissions(@current_user)
  if sprint.project.current_sprint_id
	  json.current_sprint_id sprint.project.current_sprint_id
  end
end
json.total_estimate sprint.total_estimate
json.burndownData sprint.burndown_graph

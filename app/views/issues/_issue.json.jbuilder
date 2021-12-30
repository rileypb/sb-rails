json.extract! issue, :id, :title, :description, :estimate, :progress, :created_at, :updated_at, :completed, :closable
json.state (issue.state || 'Open')
if issue.last_changed_by
	json.last_changed_by do
		json.partial! "users/user", user: issue.last_changed_by
	end
else
	json.last_changed_by nil
end
json.project_id issue.project.id
json.path issues_path(id: issue.id, format: :json)
json.permissions issue.permissions(@current_user)
json.project do
	json.id issue.project.id
	json.name issue.project.name
	json.permissions issue.project.permissions(@current_user)
end

if issue.sprint
	json.sprint do 
		json.id issue.sprint.id
		json.title issue.sprint.title
		json.completed issue.sprint.completed
	end
end

if issue.epic
	json.epic do
		json.partial! "epics/epic", epic: issue.epic
	end
end

json.tasks do
	json.array!(issue.tasks) do |task|
		json.partial! "tasks/task", task: task
	end
end

json.activities do 
	json.array!(issue.activities.order(id: :desc).limit(10)) do |activity|
		json.partial! "activities/activity", activity: activity
	end
end

if issue.assignee
	json.assignee do
		json.partial! "users/user", user: issue.assignee
	end
end

json.comments do
	json.array!(issue.comments.order(id: :desc)) do |comment|
		json.partial! "comments/comment", comment: comment
	end
end

json.acceptance_criteria do
	json.array!(issue.acceptance_criteria.order(id: :asc)) do |ac|
		json.extract! ac, :id, :criterion, :completed
	end
end


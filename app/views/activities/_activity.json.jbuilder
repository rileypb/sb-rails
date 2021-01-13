json.extract! activity, :id, :action, :modifier, :created_at
json.user do
	json.partial! "users/user", user: activity.user
end
json.project_context do
	json.id activity.project_context.id
	json.name activity.project_context.name
end
if activity.task
	json.task do
		json.partial! "tasks/task", task: activity.task
	end
end
if activity.issue
	json.issue do
		json.partial! "issues/issue_brief", issue: activity.issue
	end
end
if activity.epic
	json.epic do
		json.partial! "epics/epic_brief", epic: activity.epic
	end
end
if activity.sprint
	json.sprint do
		json.partial! "sprints/sprint", sprint: activity.sprint
	end
end
if activity.sprint2
	json.sprint2 do
		json.partial! "sprints/sprint", sprint: activity.sprint2
	end
end
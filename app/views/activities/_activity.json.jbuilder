json.extract! activity, :id, :action, :modifier, :created_at
if activity.user
	json.user do
		json.partial! "users/user", user: activity.user
	end
else
	json.user do 
		json.partial! "users/nulluser", user: nil
	end
end
if activity.user2
	json.user2 do
		json.partial! "users/user", user: activity.user2
	end
end
json.project_context do
	json.id activity.project_context.id
	json.name activity.project_context.name
end
if activity.task
	json.task do
		json.extract! activity.task, :id, :title
	end
end
if activity.issue
	json.issue do
		json.extract! activity.issue, :id, :title
	end
end
if activity.epic
	json.epic do
		json.extract! activity.epic, :id, :title
	end
end
if activity.epic2
	json.epic2 do
		json.extract! activity.epic2, :id, :title
	end
end
if activity.sprint
	json.sprint do
		json.extract! activity.sprint, :id, :title
	end
end
if activity.sprint2
	json.sprint2 do
		json.extract! activity.sprint2, :id, :title
	end
end
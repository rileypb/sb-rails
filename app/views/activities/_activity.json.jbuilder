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
		json.issue do
			json.extract! activity.task.issue, :id, :title
			json.project do 
				json.id activity.task.issue.project.id
			end
		end
	end
end
if activity.issue
	json.issue do
		json.extract! activity.issue, :id, :title
		json.project do 
			json.id activity.issue.project.id
		end
	end
end
if activity.epic
	json.epic do
		json.extract! activity.epic, :id, :title
		json.project do 
			json.id activity.epic.project.id
		end
	end
end
if activity.epic2
	json.epic2 do
		json.extract! activity.epic2, :id, :title
		json.project do 
			json.id activity.epic2.project.id
		end
	end
end
if activity.sprint
	json.sprint do
		json.extract! activity.sprint, :id, :title
		json.project do 
			json.id activity.sprint.project.id
		end
	end
end
if activity.sprint2
	json.sprint2 do
		json.extract! activity.sprint2, :id, :title
		json.project do 
			json.id activity.sprint2.project.id
		end
	end
end
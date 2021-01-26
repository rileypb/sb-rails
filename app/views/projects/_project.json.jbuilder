json.extract! project, :id, :name, :created_at, :updated_at
json.path project_path(project, format: :json)
json.permissions project.permissions(@current_user)
json.owner do
	json.id project.owner.id
	json.first_name project.owner.first_name
	json.last_name project.owner.last_name
	json.picture project.owner.picture
end

if project.current_sprint
	json.currentSprint do
		json.partial! "sprints/sprint", sprint: project.current_sprint
	end
end

json.activities do 
	json.array!(project.child_activities.order(id: :desc).limit(10)) do |activity|
		json.partial! "activities/activity", activity: activity
	end
end
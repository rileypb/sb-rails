json.extract! project, :id, :name, :created_at, :updated_at, :picture, 
					   :setting_auto_close_issues, :setting_use_acceptance_criteria,
					   :hidden
json.path project_path(project, format: :json)
json.permissions project.permissions(@current_user)
if project.owner
	json.owner do
		json.id project.owner.id
		json.first_name project.owner.first_name
		json.last_name project.owner.last_name
		json.displayName project.owner.displayName
		json.picture project.owner.picture
	end
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

json.team do
	json.array!(project.team_members(current_user)) do |user|
		json.partial! "users/user", user: user
	end
end

json.extract! epic, :id, :title, :description, :size, :color, :created_at, :updated_at
# if epic.last_changed_by 
# 	json.last_changed_by do
# 		json.partial! "users/user", user: epic.last_changed_by
# 	end
# else
# 	json.last_changed_by nil
# end
json.path project_epic_path(project_id: epic.project.id, id: epic.id, format: :json)
json.permissions epic.permissions(@current_user)
json.project do
	json.id epic.project.id
	json.name epic.project.name
	json.permissions epic.project.permissions(@current_user)
end
json.issues do
	json.array!(epic.issues_in_order) do |issue|
		json.partial! "issues/issue_brief", issue: issue
	end
end

json.activities do 
	json.array!(epic.activities.order(id: :desc).limit(10)) do |activity|
		json.partial! "activities/activity", activity: activity
	end
end

json.comments do
	json.array!(epic.comments.order(id: :desc)) do |comment|
		json.partial! "comments/comment", comment: comment
	end
end



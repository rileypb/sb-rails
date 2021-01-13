json.extract! task, :id, :title, :description, :estimate, :state, :created_at, :updated_at
if task.last_changed_by
	json.last_changed_by do
		json.partial! "users/user", user: task.last_changed_by
	end
else
	json.last_changed_by nil
end
json.issue_id task.issue_id
json.path task_path(id: task.id, format: :json)
json.permissions task.permissions(current_user)
json.issue do
	json.partial! "issues/issue_brief", issue: task.issue
	json.permissions task.issue.permissions(current_user)
end
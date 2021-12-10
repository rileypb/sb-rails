json.extract! task, :id, :title, :description, :estimate, :state

if task.assignee
	json.assignee do
		json.id task.assignee.id
		json.last_name task.assignee.last_name
		json.first_name task.assignee.first_name
	end
else
	json.assignee do
		json.id 0
		json.last_name ""
		json.first_name ""
	end
end
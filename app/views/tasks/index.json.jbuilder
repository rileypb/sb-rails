json.tasks do
	json.list @tasks, partial: "tasks/task", as: :task
	json.path issue_tasks_path	
end
json.issue do
	json.extract! @issue, :id, :title
end
json.tasks do
	json.list @tasks, partial: "tasks/task", as: :task
	json.path issue_tasks_path	
end
json.issue do
	json.extract! @issue, :id, :title
end

totalEstimate = @tasks.sum(&:estimate)
if totalEstimate == 0
	json.percentComplete -1
else
	json.percentComplete @tasks.sum { |task| task.state == "complete" ? task.estimate : 0}.to_f / totalEstimate
end
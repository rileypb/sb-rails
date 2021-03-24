json.report do
	json.sprint do
		json.partial! "sprints/sprint", sprint: @sprint
		json.total_estimate @sprint.total_estimate
		json.total_work @sprint.total_work
		json.burndownData @sprint.burndown_graph
	end
	json.issues do
		json.array!(@sprint.issues) do |issue|
			json.extract! issue, :id, :title, :description, :estimate, :completed
			json.tasks do
				json.array!(issue.tasks) do |task|
					json.extract! task, :id, :title, :description, :state, :completed_at, :estimate
					json.assignee_name (task.assignee ? "#{task.assignee.first_name} #{task.assignee.last_name}" : "unassigned")
				end
			end
		end
	end
end
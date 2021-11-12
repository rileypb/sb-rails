json.extract! issue, :id, :title, :description, :estimate, :progress, :completed
json.state (issue.state || 'Open')

if issue.epic
	json.epic do
		json.partial! "epics/epic", epic: issue.epic
	end
end

json.tasks do
	json.array!(issue.tasks) do |task|
		json.partial! "tasks/task", task: task
	end
end

json.acceptance_criteria do
	json.array!(issue.acceptance_criteria.order(id: :asc)) do |ac|
		json.extract! ac, :id, :criterion, :completed
	end
end


json.extract! issue, :id, :title, :state, :estimate, :completed

if (issue.epic)
	json.epic do
		json.id issue.epic.id
		json.title issue.epic.title
		json.color issue.epic.color
	end
end

json.project do
	json.id issue.project.id
	json.current_sprint_id issue.project.current_sprint_id
end

if issue.sprint
	json.sprint do
		json.extract! issue.sprint, :id, :title, :completed, :started
	end
end

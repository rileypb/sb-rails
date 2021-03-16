json.extract! issue, :id, :title

if (issue.epic)
	json.epic do
		json.id issue.epic.id
		json.title issue.epic.title
		json.color issue.epic.color
	end
end
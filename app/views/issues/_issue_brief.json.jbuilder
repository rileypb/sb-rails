json.extract! issue, :id, :title, :completed
json.project do
	json.partial! "projects/project_brief", project: issue.project
end
if (issue.epic)
	json.epic do
		json.id issue.epic.id
		json.title issue.epic.title
		json.color issue.epic.color
	end
end

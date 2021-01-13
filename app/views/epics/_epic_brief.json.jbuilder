json.extract! epic, :id, :title
json.project do
	json.partial! "projects/project_brief", project: epic.project
end

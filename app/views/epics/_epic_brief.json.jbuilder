json.extract! epic, :id, :title, :color
json.project do
	json.partial! "projects/project_brief", project: epic.project
end

json.epics do
	json.list @epics, partial: "epics/epic", as: :epic
	json.path project_epics_path
end
json.project do
	json.extract! @project, :id, :name
end

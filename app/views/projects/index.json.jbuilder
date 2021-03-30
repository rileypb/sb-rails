# json.array! @projects, partial: "projects/project", 
# 					   as: :project
json.projects do
	json.list @projects, partial: "projects/project_brief", as: :project
	json.permissions Project.permissions(@current_user)
	json.path projects_path
end
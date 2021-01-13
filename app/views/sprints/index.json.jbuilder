json.sprints do
	json.list @sprints, partial: "sprints/sprint", as: :sprint
	json.path project_sprints_path
end
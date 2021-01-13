json.issues do
	json.list @issues, partial: "issues/issue", as: :issue
	json.path project_all_issues_path
end
json.project do
	json.extract! @project, :id, :name
end

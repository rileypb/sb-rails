# json.array! @issues, partial: "issues/issue", 
# 					   as: :issue
json.issues do
	json.list @issues, partial: "issues/issue", as: :issue
	json.path issues_path
end
json.project do
	json.extract! @project, :id, :name
end

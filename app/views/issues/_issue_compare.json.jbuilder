json.id issue.id

json.title_old issue_old["title"]
json.title_new issue.title

json.description_old issue_old["description"]
json.description_new issue.description

json.estimate_old issue_old["estimate"]
json.estimate_new issue.estimate

json.progress_old issue_old["progress"]
json.progress_new issue.progress

json.completed_old issue_old["completed"]
json.completed_new issue.completed

json.state_old issue_old["state"]
json.state_new (issue.state || 'Open')

if issue_old["epic"]
	json.epic_old issue_old["epic"]
end

json.tasks_old issue_old["tasks"]
json.tasks_new do 
	json.array!(issue.tasks) do |task|
		json.partial! "tasks/task_compare", task: task
	end
end

json.acceptance_criteria_old issue_old["acceptance_criteria"]
json.acceptance_criteria_new do
	json.array!(issue.acceptance_criteria.order(id: :asc)) do |ac|
		json.extract! ac, :id, :criterion
	end
end

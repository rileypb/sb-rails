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


start_ac_ids = (issue_old["acceptance_criteria"] || []).map { |x| x["id"] }
end_ac_ids = (issue.acceptance_criteria || []).map(&:id)
all_ac_ids = (start_ac_ids + end_ac_ids).uniq

ac_ids_removed = start_ac_ids - end_ac_ids
ac_ids_added = end_ac_ids - start_ac_ids
ac_ids_normal = all_ac_ids - (ac_ids_removed + ac_ids_added)

json.acceptance_criteria do
	json.array!(ac_ids_normal) do |id|
		ac_old = issue_old["acceptance_criteria"].find { |x| x["id"] == id }
		ac = AcceptanceCriterion.find(id)

		json.id id
		json.criterion_old ac_old["criterion"]
		json.criterion_new ac.criterion
	end
end

json.acceptance_criteria_removed do
	json.array!(ac_ids_removed) do |id|
		ac_old = issue_old["acceptance_criteria"].find { |x| x["id"] == id }
		json.id id
		json.criterion ac_old["criterion"]
	end
end

json.acceptance_criteria_added do
	json.array!(ac_ids_added) do |id|
		ac = AcceptanceCriterion.find(id)
		json.id id
		json.criterion ac.criterion
	end
end


start_task_ids = (issue_old["tasks"] || []).map { |x| x["id"] }
end_task_ids = (issue.tasks || []).map(&:id)
all_task_ids = (start_task_ids + end_task_ids).uniq

task_ids_removed = start_task_ids - end_task_ids
task_ids_added = end_task_ids - start_task_ids
task_ids_normal = all_task_ids - (task_ids_removed + task_ids_added)

json.tasks do
	json.array!(task_ids_normal) do |id|
		task_old = issue_old["tasks"].find { |x| x["id"] == id }
		task = Task.find(id)

		json.id id
		json.title_old task_old["title"]
		json.title_new task.title
		json.description_old task_old["description"]
		json.description_new task.description
		json.estimate_old task_old["estimate"]
		json.estimate_new task.estimate
	end
end

json.tasks_removed do
	json.array!(task_ids_removed) do |id|
		task_old = issue_old["tasks"].find { |x| x["id"] == id }
		json.id id
		json.title task_old["title"]
		json.description task_old["description"]
		json.estimate task_old["estimate"]
	end
end

json.tasks_added do
	json.array!(task_ids_added) do |id|
		task = Task.find(id)
		json.id id
		json.title task.title
		json.description task.description
		json.estimate task.estimate
	end
end


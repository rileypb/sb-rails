json.teacher_report do
	json.id @sprint.id

	issues = @final["original_issues"]
	incomplete_issues = issues.filter { |issue| !issue["completed"] }
	if incomplete_issues.present?
		json.incompleteIssues do
			json.array!(incomplete_issues) do |issue|
				json.id issue["id"]
				json.title issue["title"]
			end
		end
	end

	incomplete_tasks = issues.map { |issue| issue["tasks"].filter { |task| !task["completed"] } }.flatten
	if incomplete_tasks.present?
		json.incompleteTasks do
			json.array!(incomplete_tasks) do |task|
				json.id task["id"]
				json.title task["title"]
			end
		end
	end

end
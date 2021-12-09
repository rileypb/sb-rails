json.comparison do
	json.id @sprint.id

	json.title_old @snapshot["title"]
	json.title_new @sprint.title

	json.goal_old @snapshot["goal"]
	json.goal_new @sprint.goal

	json.description_old @snapshot["description"]
	json.description_new @sprint.description

	json.starting_work_old @snapshot["starting_work"]
	json.starting_work_new @sprint.starting_work

	start_issue_ids = @snapshot["original_issues"].map { |x| x["id"] }
	end_issue_ids = @sprint.issues.map(&:id)
	all_issue_ids = (start_issue_ids + end_issue_ids).uniq

	issue_ids_removed = start_issue_ids - end_issue_ids
	issue_ids_added = end_issue_ids - start_issue_ids
	issue_ids_normal = all_issue_ids - (issue_ids_removed + issue_ids_added)

	json.issues do
		json.array!(issue_ids_normal) do |id|
			issue_old = @snapshot["original_issues"].find { |x| x["id"] == id }
			issue = Issue.find(id)
		
			json.partial! "issues/issue_compare", issue_old: issue_old, issue: issue
		end
	end

	json.added_issues do
		json.array!(issue_ids_added) do |id|
			json.id id
			issue = Issue.find(id)
			json.title issue.title
			json.description issue.description
			json.estimate issue.estimate
			if issue.epic
				json.epic do
					json.title issue.epic.title
				end
			end

			json.acceptance_criteria do
				json.array!(issue.acceptance_criteria) do |ac|
					json.id ac.id
					json.criterion ac.criterion
				end
			end
		end
	end

	json.removed_issues do
		json.array!(issue_ids_removed) do |id|
			json.id id
			issue = Issue.find(id)
			json.title issue.title
			json.description issue.description
			json.estimate issue.estimate
			if issue.epic
				json.epic do
					json.title issue.epic.title
				end
			end
		end
	end
end
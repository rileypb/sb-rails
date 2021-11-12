json.sprint_snapshot do
	json.id @sprint.id
	json.title @sprint.title
	json.goal @sprint.goal
	json.description @sprint.description
	json.start_date @sprint.start_date
	json.end_date @sprint.end_date
	json.starting_work @sprint.starting_work
	json.actual_end_date @sprint.actual_end_date
	json.original_issues do
		json.array!(@sprint.issues) do |issue|
			json.partial! "issues/issue_snapshot", issue: issue
		end
	end

end

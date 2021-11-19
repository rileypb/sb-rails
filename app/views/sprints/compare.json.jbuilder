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

	issue_ids = []
	issue_ids += @snapshot["original_issues"].map { |x| x["id"] }
	issue_ids += @sprint.issues.map(&:id)
	issue_ids.uniq!

	json.issues do
		json.array!(@snapshot["original_issues"]) do |oi|
			json.foo do
				json.bar "foobar"
			end
		end
	end
end
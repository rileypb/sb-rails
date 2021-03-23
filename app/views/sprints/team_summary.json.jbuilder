json.team do
	json.members do
		json.array!(@sprint.project.team_members(current_user)) do |member|
			json.partial! "users/user", user: member
			json.work do
				work = 0
				json.assigned_issues do
		 			json.array!(member.assigned_issues.filter {|i| i.sprint == @sprint}) do |issue|
						json.extract! issue, :id, :title
						json.assigned_tasks do
							json.array!(member.assigned_tasks.filter {|t| t.issue == issue}) do |task|
				 				work += task.estimate
								json.partial! "tasks/task", task: task
							end
						end
					end
				end
				json.work work
		 	end
		end
	end
	json.unassignedWork do
		json.unassigned_issues do
			json.array!(@sprint.unassigned_issues) do |issue|
				json.extract! issue, :id, :title
				json.unassigned_tasks do
					json.array!(issue.tasks.filter {|t| !t.assignee}) do |task|
						json.partial! "tasks/task", task: task
					end
				end
			end
		end
	end
end
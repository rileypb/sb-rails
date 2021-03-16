class TransferController < ApplicationController
	before_action :security_check, only: []

	def transfer_issues
    	transfer_params = params.require(:transfer).permit(:projectId1, :sprintId1, :epicId1, :fromIndex, :projectId2, :sprintId2, :epicId2, :toIndex)
    	if (transfer_params[:epicId1])
    		transfer_between_epics(transfer_params)
    	else
    		transferBetweenProjectsAndSprints(transfer_params)
    	end
	end

	def transferBetweenProjectsAndSprints(transfer_params)
		puts "transfer: #{transfer_params}"
		Issue.transaction do
			project1 = transfer_params[:projectId1] && Project.find(transfer_params[:projectId1])
			sprint1 = transfer_params[:sprintId1] && Sprint.find(transfer_params[:sprintId1])
			project2 = transfer_params[:projectId2] && Project.find(transfer_params[:projectId2])
			sprint2 = transfer_params[:sprintId2] && Sprint.find(transfer_params[:sprintId2])

			container1 = project1 || sprint1
			container2 = project2 || sprint2

			raise ActiveRecord::RecordNotFound if !(container1 && container2)

			issue_order1 = container1.issue_order || default_issue_order(container1)
			issue_order2 = container2.issue_order || default_issue_order(container2)

			moved_element = issue_order1.split(',')[transfer_params[:fromIndex].to_i]
			moved_issue = Issue.find(moved_element)
			if sprint2
				moved_issue.update!(sprint: sprint2)
			else
				moved_issue.update!(sprint: nil)
			end
			container1.update!(issue_order: remove_from_order_at(issue_order1, transfer_params[:fromIndex].to_i))
			container2.update!(issue_order: insert_into_order(issue_order2, moved_element, transfer_params[:toIndex].to_i))



			projects = []
			if sprint1
				sync_on "sprints/#{sprint1.id}/issues"
				sync_on "sprints/#{sprint1.id}"
				projects << sprint1.project
			end
			if sprint2
				sync_on "sprints/#{sprint2.id}/issues"
				sync_on "sprints/#{sprint2.id}"
				projects << sprint2.project
			end
			if project1
				sync_on "projects/#{project1.id}/issues"
				sync_on "projects/#{project1.id}"
				projects << project1
			end
			if project2
				sync_on "projects/#{project2.id}/issues"
				sync_on "projects/#{project2.id}"
				projects << project2
			end

			projects.uniq! 
			projects.each do |p|
		        p.update_burndown_data!
				sync_on_activities(p)
			end

			create_transfer_activity_for(moved_issue)
		end
	end

    def create_transfer_activity_for(issue)
      if issue.sprint.nil? && issue.sprint_id_before_last_save.present?
        Activity.create(user: current_user, action: 'moved_issue_to_product_backlog', issue: issue, sprint_id: issue.sprint_id_before_last_save, project: issue.project, project_context: issue.project)
      elsif issue.sprint_id_before_last_save.nil? && issue.sprint.present?
        Activity.create(user: current_user, action: 'assigned_issue_to_sprint', issue: issue, sprint: issue.sprint, project: issue.project, project_context: issue.project)
      elsif issue.sprint_id_before_last_save != issue.sprint_id
        old_sprint = Sprint.find(issue.sprint_id_before_last_save)
        Activity.create(user: current_user, action: 'moved_issue_between_sprints', issue: issue, sprint: issue.sprint, sprint2: old_sprint, project_context: issue.project)
      end
    end

	def transfer_between_epics(transfer_params)
		Epic.transaction do
			epic1 = Epic.find(transfer_params[:epicId1])
			epic2 = Epic.find(transfer_params[:epicId2])

			old_order1 = epic1.issue_order
			old_order1_split = (old_order1 || default_issue_order(epic1)).split(',')

			old_order2 = epic2.issue_order
			old_order2_split = (old_order2 || default_issue_order(epic2)).split(',')

			from_index = transfer_params[:fromIndex].to_i
			to_index = transfer_params[:toIndex].to_i

			moved_id = old_order1_split.delete_at(from_index)
			old_order2_split.insert(to_index, moved_id)

			moved_issue = Issue.find(moved_id)
			moved_issue.update(epic: epic2)

			epic1.update(issue_order: old_order1_split.join(','))
			epic2.update(issue_order: old_order2_split.join(','))

			Activity.create(user: current_user, action: "moved_issue_between_epics", issue: moved_issue, epic: epic1, epic2: epic2, project_context: epic1.project)
			sync_on "issues/#{moved_id}"
			sync_on "projects/#{moved_issue.project.id}/issues/*"
			sync_on "projects/#{moved_issue.project.id}"
			sync_on "sprints/#{moved_issue.sprint_id}/issues/*" if moved_issue.sprint_id

			sync_on "epics/#{epic1.id}"
			sync_on "epics/#{epic2.id}"
			sync_on "epics/#{epic1.id}/issues"
			sync_on "epics/#{epic1.id}/issues/*"
			sync_on "epics/#{epic2.id}/issues"
			sync_on "epics/#{epic2.id}/issues/*"

			sync_on_activities(moved_issue.project)
		end
	end
end
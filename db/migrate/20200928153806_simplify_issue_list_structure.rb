class SimplifyIssueListStructure < ActiveRecord::Migration[6.0]
  def change

  	add_column :projects, :issue_order, :string
  	add_column :sprints, :issue_order, :string

  	add_reference :issues, :sprint

  	Project.all.each do |project|
  		issue_list = project.issue_list
  		project.update!(issue_order: issue_list.order)
  	end 

  	Sprint.all.each do |sprint|
  		issue_list = sprint.backlog
  		sprint.update!(issue_order: issue_list.order)
		issue_list.issues.each do |issue|
			issue.update!(sprint: sprint)
		end
	end

	remove_column :issues, :issue_list_id, :integer
	remove_column :projects, :issue_list_id, :integer
	remove_column :sprints, :backlog_id, :integer

	drop_table :issue_lists
  end
end

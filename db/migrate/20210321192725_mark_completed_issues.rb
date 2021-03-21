class MarkCompletedIssues < ActiveRecord::Migration[6.1]
  def change
  	Issue.transaction do
  		j = Issue.joins("INNER JOIN sprints ON issues.sprint_id = sprints.id")
	  	issues = j.where('sprints.completed = true AND issues.state="Closed"')
	  	issues.find_each { |issue| issue.update!(completed: true) }
	end
  end
end

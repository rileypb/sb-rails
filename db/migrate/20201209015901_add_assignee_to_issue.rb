class AddAssigneeToIssue < ActiveRecord::Migration[6.1]
  def change
  	add_reference :issues, :assignee, foreign_key: { to_table: :users }, optional: true
  end
end

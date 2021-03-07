class AddAssigneeToTasks < ActiveRecord::Migration[6.1]
  def change
  	add_reference :tasks, :assignee, foreign_key: { to_table: :users }, optional: true
  end
end

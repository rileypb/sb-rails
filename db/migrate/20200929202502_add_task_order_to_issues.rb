class AddTaskOrderToIssues < ActiveRecord::Migration[6.0]
  def change
  	add_column :issues, :task_order, :string
  end
end

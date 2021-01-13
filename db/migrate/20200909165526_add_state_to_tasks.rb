class AddStateToTasks < ActiveRecord::Migration[6.0]
  def change
  	add_column :tasks, :state, :string
  end
end

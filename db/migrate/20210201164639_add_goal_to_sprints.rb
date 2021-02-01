class AddGoalToSprints < ActiveRecord::Migration[6.1]
  def change
  	add_column :sprints, :goal, :string
  end
end

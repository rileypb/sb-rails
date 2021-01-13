class AddCurrentSprintToProject < ActiveRecord::Migration[6.0]
  def change
  	add_reference :projects, :current_sprint, foreign_key: { to_table: :sprints }, optional: true
  end
end

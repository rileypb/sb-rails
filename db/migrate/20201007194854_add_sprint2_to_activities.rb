class AddSprint2ToActivities < ActiveRecord::Migration[6.0]
  def change
  	add_reference :activities, :sprint2, foreign_key: { to_table: :sprints }, optional: true
  end
end

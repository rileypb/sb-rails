class AddEpic2ToActivities < ActiveRecord::Migration[6.0]
  def change
  	add_reference :activities, :epic2, foreign_key: { to_table: :epics }, optional: true
  end
end

class RemoveActivitySprint2ForeignKey < ActiveRecord::Migration[6.1]
  def change
  	if foreign_key_exists?(:activities, column: :sprint2_id)
  		remove_foreign_key(:activities, :sprints, column: :sprint2_id)
  	end
  	if foreign_key_exists?(:activities, column: :epic2_id)
  		remove_foreign_key(:activities, :epics, column: :epic2_id)
  	end
  end
end

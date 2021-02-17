class AddActualEndDateToSprint < ActiveRecord::Migration[6.1]
  def change
  	add_column :sprints, :actual_end_date, :date
  end
end

class AddEndDateToSprints < ActiveRecord::Migration[6.0]
  def change
  	add_column :sprints, :started, :boolean
  	add_column :sprints, :completed, :boolean
  	add_column :sprints, :start_date, :date
  	add_column :sprints, :end_date, :date
  	add_column :sprints, :starting_work, :integer
  end
end

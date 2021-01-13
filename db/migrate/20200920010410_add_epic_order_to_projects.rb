class AddEpicOrderToProjects < ActiveRecord::Migration[6.0]
  def change
  	add_column :projects, :epic_order, :string
  end
end

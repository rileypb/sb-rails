class AddDemoFlagToProject < ActiveRecord::Migration[6.1]
  def change
  	add_column :projects, :demo, :boolean
  end
end

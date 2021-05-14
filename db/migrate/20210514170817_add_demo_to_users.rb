class AddDemoToUsers < ActiveRecord::Migration[6.1]
  def change
  	add_column :users, :demo, :boolean
  end
end

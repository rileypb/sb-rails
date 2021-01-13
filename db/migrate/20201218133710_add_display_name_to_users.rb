class AddDisplayNameToUsers < ActiveRecord::Migration[6.1]
  def change
  	add_column :users, :displayName, :string
  end
end

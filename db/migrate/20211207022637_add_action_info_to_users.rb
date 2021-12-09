class AddActionInfoToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :action_count, :integer
    add_column :users, :last_action, :datetime
  end
end

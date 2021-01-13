class AddPermissionScopeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :permission_scope, :string
  end
end

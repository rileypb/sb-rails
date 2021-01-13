class AddPermissionScopesToProjectPermissions < ActiveRecord::Migration[5.2]
  def change
    add_column :project_permissions, :permission_scope, :string
  end
end

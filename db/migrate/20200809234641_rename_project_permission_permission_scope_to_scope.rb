class RenameProjectPermissionPermissionScopeToScope < ActiveRecord::Migration[5.2]
  def change
  	rename_column :project_permissions, :permission_scope, :scope 
  end
end

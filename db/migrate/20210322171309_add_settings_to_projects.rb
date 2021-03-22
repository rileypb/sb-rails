class AddSettingsToProjects < ActiveRecord::Migration[6.1]
  def change
  	add_column :projects, :setting_auto_close_issues, :boolean, null: false, default: false
    add_column :projects, :picture, :string
  end
end

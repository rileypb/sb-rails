class RemoveProgressFromIssues < ActiveRecord::Migration[6.0]
  def change
  	remove_column :issues, :progress, :integer
  end
end

class AddCompletedToIssue < ActiveRecord::Migration[6.1]
  def change
  	add_column :issues, :completed, :boolean, null: false, default: false
  end
end

class AddIssueOrderToEpics < ActiveRecord::Migration[6.0]
  def change
  	add_column :epics, :issue_order, :string
  end
end

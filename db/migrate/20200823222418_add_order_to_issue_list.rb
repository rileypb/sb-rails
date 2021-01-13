class AddOrderToIssueList < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_lists, :order, :string
  end
end

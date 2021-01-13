class AddParentToIssues < ActiveRecord::Migration[6.0]
  def change
  	add_reference :issues, :parent, foreign_key: { to_table: :issues }, optional: true
  end
end

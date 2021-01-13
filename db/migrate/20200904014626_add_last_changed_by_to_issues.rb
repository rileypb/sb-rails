class AddLastChangedByToIssues < ActiveRecord::Migration[6.0]
  def change
    add_reference :issues, :last_changed_by, foreign_key: { to_table: :users }
  end
end

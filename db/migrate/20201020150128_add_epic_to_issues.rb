class AddEpicToIssues < ActiveRecord::Migration[6.0]
  def change
  	add_reference :issues, :epic, foreign_key: true, optional: true
  end
end

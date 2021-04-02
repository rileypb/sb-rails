class RemoveCommentForeignKeys < ActiveRecord::Migration[6.1]
  def change
  	remove_foreign_key :comments, :epics
  	remove_foreign_key :comments, :issues
  	remove_foreign_key :comments, :projects, column: :project_id
  	remove_foreign_key :comments, :projects, column: :project_context_id
  	remove_foreign_key :comments, :sprints
  	remove_foreign_key :comments, :users
  end
end

class AddAllowIssueCompletionWithoutSprint < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :allow_issue_completion_without_sprint, :boolean, default: false
  end
end

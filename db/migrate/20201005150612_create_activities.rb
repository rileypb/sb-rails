class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :activities do |t|
      # example: _John_Smith_ set state of _Issue_#100_ to In Progress
      # user = John Smith
      # issue = Issue #100
      # action = set state
      # modifier = In Progress 
      t.references :user
      t.string :action 
      t.string :modifier 

      t.references :project, optional: true
      t.references :sprint, optional: true
      t.references :issue, optional: true
      t.references :task, optional: true
      t.references :epic, optional: true

      t.references :project_context, foreign_key: { to_table: :projects }

      t.timestamps 
    end
  end
end

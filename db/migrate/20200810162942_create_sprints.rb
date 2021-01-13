class CreateSprints < ActiveRecord::Migration[5.2]
  def change
    create_table :sprints do |t|
      t.string :title
      t.string :description

      t.references :project, foreign_key: true
      t.references :backlog, foreign_key: { to_table: :issue_lists }

      t.timestamps
    end
  end
end

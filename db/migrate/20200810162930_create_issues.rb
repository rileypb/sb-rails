class CreateIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :issues do |t|
      t.string :title
      t.text :description
      t.string :estimate
      t.string :state
      t.integer :progress

      t.references :issue_list, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end

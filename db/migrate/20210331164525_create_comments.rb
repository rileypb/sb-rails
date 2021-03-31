class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :text

      t.references :user, null: false, foreign_key: true
      t.references :issue, foreign_key: true
      t.references :epic, foreign_key: true
      t.references :sprint, foreign_key: true
      t.references :project, foreign_key: true

      t.references :project_context, null: false, foreign_key: { to_table: :projects }

      t.timestamps
    end
  end
end

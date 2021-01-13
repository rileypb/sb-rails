class CreateTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.integer :estimate
      t.references :issue
      t.references :last_changed_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end

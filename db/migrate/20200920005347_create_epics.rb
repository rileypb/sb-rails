class CreateEpics < ActiveRecord::Migration[6.0]
  def change
    create_table :epics do |t|
      t.string :title
      t.text :description
      t.integer :size
      t.references :project
      t.string :color

      t.timestamps
    end
  end
end

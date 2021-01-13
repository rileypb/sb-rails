class CreateBurndownData < ActiveRecord::Migration[6.1]
  def change
    create_table :burndown_data do |t|
      t.integer :day
      t.integer :value
      t.references :sprint, null: false, foreign_key: true
    end
  end
end

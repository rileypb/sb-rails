class CreateAcceptanceCriteria < ActiveRecord::Migration[6.1]
  def change
    create_table :acceptance_criteria do |t|
      t.text :criterion, null: false
      t.boolean :completed, null: false, default: false
      t.references :issue, null: false

      t.timestamps
    end
  end
end

class CreateIssueLists < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_lists do |t|
      t.string :name

      t.timestamps
    end
  end
end

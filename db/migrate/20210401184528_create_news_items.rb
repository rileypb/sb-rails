class CreateNewsItems < ActiveRecord::Migration[6.1]
  def change
    create_table :news_items do |t|
      t.references :comment, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.boolean :seen

      t.timestamps
    end
  end
end

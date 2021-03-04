class AddUser2ToActivity < ActiveRecord::Migration[6.1]
  def change
  	add_reference :activities, :user2, foreign_key: { to_table: :users }, optional: true
  end
end

class AddRetrospectiveToSprints < ActiveRecord::Migration[6.1]
  def change
  	add_column :sprints, :retrospective, :string
  end
end

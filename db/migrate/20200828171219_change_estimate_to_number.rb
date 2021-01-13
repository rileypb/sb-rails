class ChangeEstimateToNumber < ActiveRecord::Migration[5.2]
  def change
  	change_column :issues, :estimate, :integer
  end
end

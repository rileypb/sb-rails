class ChangeEstimateToNumber < ActiveRecord::Migration[5.2]
  def change
  	change_column :issues, :estimate, 'integer USING CAST(column_name AS integer)'
  end
end

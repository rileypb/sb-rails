class ChangeEstimateToNumber < ActiveRecord::Migration[5.2]
  def change
    # make this work in sqlite3
    if Rails.env.development?
      change_column :issues, :estimate, :integer
    else
    	change_column :issues, :estimate, 'integer USING CAST(estimate AS integer)'
    end
  end
end

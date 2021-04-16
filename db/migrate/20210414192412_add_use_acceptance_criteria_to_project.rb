class AddUseAcceptanceCriteriaToProject < ActiveRecord::Migration[6.1]
  def change
  	add_column :projects, :setting_use_acceptance_criteria, :boolean, null: false, default: false
  end
end

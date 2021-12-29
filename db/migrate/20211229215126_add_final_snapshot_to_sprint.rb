class AddFinalSnapshotToSprint < ActiveRecord::Migration[6.1]
  def change
    add_column :sprints, :final_snapshot, :text, default: nil
  end
end

class AddSnapshotToSprint < ActiveRecord::Migration[6.1]
  def change
    add_column :sprints, :snapshot, :text, default: nil
  end
end

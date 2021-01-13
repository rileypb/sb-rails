class AddProductBacklogToProject < ActiveRecord::Migration[5.2]
  def change
  	add_reference :projects, :issue_list, index: true
  end
end

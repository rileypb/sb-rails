class AddKeyToProject < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :key, :string, default: nil

    Project.all.filter { |p| !p.key }.each do |p|
      p.update(key: Array.new(Project::KEY_LENGTH){[*"a".."z", *"0".."9"].sample}.join)
    end
  end
end

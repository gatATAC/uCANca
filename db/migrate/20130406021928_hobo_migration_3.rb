class HoboMigration3 < ActiveRecord::Migration
  def self.up
    add_column :node_edges, :position, :integer
  end

  def self.down
    remove_column :node_edges, :position
  end
end

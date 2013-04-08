class HoboMigration6 < ActiveRecord::Migration
  def self.up
    add_column :sub_system_flows, :position, :integer
  end

  def self.down
    remove_column :sub_system_flows, :position
  end
end

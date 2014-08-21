class HoboMigration64 < ActiveRecord::Migration
  def self.up
    add_column :sub_system_flows, :context_name, :string
  end

  def self.down
    remove_column :sub_system_flows, :context_name
  end
end

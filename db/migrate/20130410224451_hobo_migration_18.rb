class HoboMigration18 < ActiveRecord::Migration
  def self.up
    add_column :flow_types, :enable_input, :boolean, :default => :true
    add_column :flow_types, :enable_output, :boolean, :default => :true
  end

  def self.down
    remove_column :flow_types, :enable_input
    remove_column :flow_types, :enable_output
  end
end

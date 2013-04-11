class HoboMigration15 < ActiveRecord::Migration
  def self.up
    add_column :flow_types, :c_type, :string
  end

  def self.down
    remove_column :flow_types, :c_type
  end
end

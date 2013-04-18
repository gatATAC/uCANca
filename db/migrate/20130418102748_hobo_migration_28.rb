class HoboMigration28 < ActiveRecord::Migration
  def self.up
    add_column :function_sub_systems, :implementacion, :boolean, :default => :false
  end

  def self.down
    remove_column :function_sub_systems, :implementacion
  end
end

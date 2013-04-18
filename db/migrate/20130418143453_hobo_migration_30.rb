class HoboMigration30 < ActiveRecord::Migration
  def self.up
    change_column :function_sub_systems, :implementacion, :boolean, :default => :false
  end

  def self.down
    change_column :function_sub_systems, :implementacion, :boolean, :default => false
  end
end

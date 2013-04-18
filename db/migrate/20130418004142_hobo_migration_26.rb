class HoboMigration26 < ActiveRecord::Migration
  def self.up
    add_column :function_sub_systems, :position, :integer
  end

  def self.down
    remove_column :function_sub_systems, :position
  end
end

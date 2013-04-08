class HoboMigration8 < ActiveRecord::Migration
  def self.up
    add_column :sub_systems, :position, :integer
  end

  def self.down
    remove_column :sub_systems, :position
  end
end

class HoboMigration7 < ActiveRecord::Migration
  def self.up
    add_column :connectors, :position, :integer
  end

  def self.down
    remove_column :connectors, :position
  end
end

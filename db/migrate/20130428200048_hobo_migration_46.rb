class HoboMigration46 < ActiveRecord::Migration
  def self.up
    add_column :users, :developer, :boolean, :default => false
  end

  def self.down
    remove_column :users, :developer
  end
end

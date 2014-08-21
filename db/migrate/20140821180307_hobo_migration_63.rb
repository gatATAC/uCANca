class HoboMigration63 < ActiveRecord::Migration
  def self.up
    add_column :projects, :abbrev, :string
  end

  def self.down
    remove_column :projects, :abbrev
  end
end

class HoboMigration38 < ActiveRecord::Migration
  def self.up
    add_column :flows, :puntero, :boolean, :default => :false
  end

  def self.down
    remove_column :flows, :puntero
  end
end

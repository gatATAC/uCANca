class HoboMigration65 < ActiveRecord::Migration
  def self.up
    remove_column :faults, :system_failsafe_mode
  end

  def self.down
    add_column :faults, :system_failsafe_mode, :text
  end
end

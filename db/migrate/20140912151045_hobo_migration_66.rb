class HoboMigration66 < ActiveRecord::Migration
  def self.up
    add_column :faults, :failure_flag, :string
    add_column :faults, :test_completed_flag, :string
    add_column :faults, :diag_activate_flag, :string
  end

  def self.down
    remove_column :faults, :failure_flag
    remove_column :faults, :test_completed_flag
    remove_column :faults, :diag_activate_flag
  end
end

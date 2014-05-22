class HoboMigration54 < ActiveRecord::Migration
  def self.up
    add_column :fail_safe_command_times, :project_id, :integer

    add_index :fail_safe_command_times, [:project_id]
  end

  def self.down
    remove_column :fail_safe_command_times, :project_id

    remove_index :fail_safe_command_times, :name => :index_fail_safe_command_times_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

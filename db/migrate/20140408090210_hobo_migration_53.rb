class HoboMigration53 < ActiveRecord::Migration
  def self.up
    add_column :fail_safe_commands, :project_id, :integer

    add_index :fail_safe_commands, [:project_id]
  end

  def self.down
    remove_column :fail_safe_commands, :project_id

    remove_index :fail_safe_commands, :name => :index_fail_safe_commands_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

class HoboMigration76 < ActiveRecord::Migration
  def self.up
    add_column :uds_sessions, :project_id, :integer

    add_index :uds_sessions, [:project_id]
  end

  def self.down
    remove_column :uds_sessions, :project_id

    remove_index :uds_sessions, :name => :index_uds_sessions_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

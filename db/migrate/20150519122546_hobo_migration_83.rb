class HoboMigration83 < ActiveRecord::Migration
  def self.up
    add_column :uds_service_managers, :project_id, :integer

    add_index :uds_service_managers, [:project_id]
  end

  def self.down
    remove_column :uds_service_managers, :project_id

    remove_index :uds_service_managers, :name => :index_uds_service_managers_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

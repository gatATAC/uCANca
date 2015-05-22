class HoboMigration80 < ActiveRecord::Migration
  def self.up
    add_column :uds_services, :project_id, :integer

    add_index :uds_services, [:project_id]
  end

  def self.down
    remove_column :uds_services, :project_id

    remove_index :uds_services, :name => :index_uds_services_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

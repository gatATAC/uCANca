class HoboMigration82 < ActiveRecord::Migration
  def self.up
    add_column :uds_service_identifiers, :uds_service_id, :integer

    add_index :uds_service_identifiers, [:uds_service_id]
  end

  def self.down
    remove_column :uds_service_identifiers, :uds_service_id

    remove_index :uds_service_identifiers, :name => :index_uds_service_identifiers_on_uds_service_id rescue ActiveRecord::StatementInvalid
  end
end

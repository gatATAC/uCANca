class HoboMigration81 < ActiveRecord::Migration
  def self.up
    add_column :uds_service_fixed_params, :uds_service_id, :integer

    add_index :uds_service_fixed_params, [:uds_service_id]
  end

  def self.down
    remove_column :uds_service_fixed_params, :uds_service_id

    remove_index :uds_service_fixed_params, :name => :index_uds_service_fixed_params_on_uds_service_id rescue ActiveRecord::StatementInvalid
  end
end

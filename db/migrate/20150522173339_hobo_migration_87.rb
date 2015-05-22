class HoboMigration87 < ActiveRecord::Migration
  def self.up
    add_column :uds_sub_services, :configuration_switch_id, :integer

    add_column :uds_services, :configuration_switch_id, :integer

    add_column :uds_service_fixed_params, :configuration_switch_id, :integer

    add_index :uds_sub_services, [:configuration_switch_id]

    add_index :uds_services, [:configuration_switch_id]

    add_index :uds_service_fixed_params, [:configuration_switch_id]
  end

  def self.down
    remove_column :uds_sub_services, :configuration_switch_id

    remove_column :uds_services, :configuration_switch_id

    remove_column :uds_service_fixed_params, :configuration_switch_id

    remove_index :uds_sub_services, :name => :index_uds_sub_services_on_configuration_switch_id rescue ActiveRecord::StatementInvalid

    remove_index :uds_services, :name => :index_uds_services_on_configuration_switch_id rescue ActiveRecord::StatementInvalid

    remove_index :uds_service_fixed_params, :name => :index_uds_service_fixed_params_on_configuration_switch_id rescue ActiveRecord::StatementInvalid
  end
end

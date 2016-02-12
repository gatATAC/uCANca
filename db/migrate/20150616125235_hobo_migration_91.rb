class HoboMigration91 < ActiveRecord::Migration
  def self.up
    add_column :uds_sub_services, :custom_code, :text
    add_column :uds_sub_services, :generate, :boolean, :default => true

    add_column :uds_services, :custom_code, :text
    add_column :uds_services, :generate, :boolean, :default => true

    remove_index(:uds_service_fixed_params, [:configuration_switch_id])
    remove_index(:uds_service_fixed_params, [:uds_sub_service_id])
    change_column :uds_service_fixed_params, :generate, :boolean, :default => true
    add_index(:uds_service_fixed_params, [:configuration_switch_id], :name => "add_index_to_fixparam_cfgswtch")
    add_index(:uds_service_fixed_params, [:uds_sub_service_id], :name => "add_index_to_fixparam_subserv")
  
  end

  def self.down
    remove_column :uds_sub_services, :custom_code
    remove_column :uds_sub_services, :generate

    remove_column :uds_services, :custom_code
    remove_column :uds_services, :generate

    remove_index(:uds_service_fixed_params, :name => "add_index_to_fixparam_cfgswtch")
    remove_index(:uds_service_fixed_params, :name => "add_index_to_fixparam_subserv")
    change_column :uds_service_fixed_params, :generate, :boolean
    add_index(:uds_service_fixed_params, [:configuration_switch_id])
    add_index(:uds_service_fixed_params, [:uds_sub_service_id])
  end
end

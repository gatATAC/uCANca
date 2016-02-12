class HoboMigration91 < ActiveRecord::Migration
  def self.up
    add_column :uds_sub_services, :custom_code, :text
    add_column :uds_sub_services, :generate, :boolean, :default => true

    add_column :uds_services, :custom_code, :text
    add_column :uds_services, :generate, :boolean, :default => true

    remove_index(:uds_service_fixed_params, [:configuration_switch_id])
    change_column :uds_service_fixed_params, :generate, :boolean, :default => true
    add_index(:uds_service_fixed_params, [:configuration_switch_id], :name => "add_index_to_fixparam_cfgswtch")
    
  
  end

  def self.down
    remove_column :uds_sub_services, :custom_code
    remove_column :uds_sub_services, :generate

    remove_column :uds_services, :custom_code
    remove_column :uds_services, :generate

    remove_index(:uds_service_fixed_params, :name => "add_index_to_fixparam_cfgswtch")
    change_column :uds_service_fixed_params, :generate, :boolean
    add_index(:uds_service_fixed_params, [:configuration_switch_id])
  end
end

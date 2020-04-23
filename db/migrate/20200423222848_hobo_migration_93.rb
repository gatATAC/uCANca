class HoboMigration93 < ActiveRecord::Migration
  def self.up
    change_column :uds_service_fixed_params, :generate, :boolean, :default => nil

    add_column :flow_types, :c_getter_patron, :text
    add_column :flow_types, :c_setter_patron, :text
    add_column :flow_types, :enable_getter, :boolean, :default => true
    add_column :flow_types, :enable_setter, :boolean, :default => true

    add_column :flow_type_targets, :c_getter_patron, :text
    add_column :flow_type_targets, :c_setter_patron, :text
    add_column :flow_type_targets, :enable_getter, :boolean, :default => true
    add_column :flow_type_targets, :enable_setter, :boolean, :default => true

    remove_index :uds_service_fixed_params, :name => :add_index_to_fixparam_subserv rescue ActiveRecord::StatementInvalid
    remove_index :uds_service_fixed_params, :name => :add_index_to_fixparam_cfgswtch rescue ActiveRecord::StatementInvalid
    add_index :uds_service_fixed_params, [:uds_sub_service_id]
    add_index :uds_service_fixed_params, [:configuration_switch_id]
  end

  def self.down
    change_column :uds_service_fixed_params, :generate, :boolean, :default => true

    remove_column :flow_types, :c_getter_patron
    remove_column :flow_types, :c_setter_patron
    remove_column :flow_types, :enable_getter
    remove_column :flow_types, :enable_setter

    remove_column :flow_type_targets, :c_getter_patron
    remove_column :flow_type_targets, :c_setter_patron
    remove_column :flow_type_targets, :enable_getter
    remove_column :flow_type_targets, :enable_setter

    remove_index :uds_service_fixed_params, :name => :index_uds_service_fixed_params_on_uds_sub_service_id rescue ActiveRecord::StatementInvalid
    remove_index :uds_service_fixed_params, :name => :index_uds_service_fixed_params_on_configuration_switch_id rescue ActiveRecord::StatementInvalid
    add_index :uds_service_fixed_params, [:uds_sub_service_id], :name => 'add_index_to_fixparam_subserv'
    add_index :uds_service_fixed_params, [:configuration_switch_id], :name => 'add_index_to_fixparam_cfgswtch'
  end
end

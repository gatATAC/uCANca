class HoboMigration91 < ActiveRecord::Migration
  def self.up
    add_column :uds_sub_services, :custom_code, :text
    add_column :uds_sub_services, :generate, :boolean, :default => true

    add_column :uds_services, :custom_code, :text
    add_column :uds_services, :generate, :boolean, :default => true

    change_column :uds_service_fixed_params, :generate, :boolean, :default => true
  end

  def self.down
    remove_column :uds_sub_services, :custom_code
    remove_column :uds_sub_services, :generate

    remove_column :uds_services, :custom_code
    remove_column :uds_services, :generate

    change_column :uds_service_fixed_params, :generate, :boolean
  end
end

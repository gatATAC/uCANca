class HoboMigration90 < ActiveRecord::Migration
  def self.up
    add_column :uds_service_fixed_params, :custom_code, :text
    add_column :uds_service_fixed_params, :generate, :boolean
  end

  def self.down
    remove_column :uds_service_fixed_params, :custom_code
    remove_column :uds_service_fixed_params, :generate
  end
end

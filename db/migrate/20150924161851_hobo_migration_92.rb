class HoboMigration92 < ActiveRecord::Migration
  def self.up
    add_column :uds_service_fixed_params, :data_size, :integer
  end

  def self.down
    remove_column :uds_service_fixed_params, :data_size
  end
end

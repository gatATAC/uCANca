class HoboMigration88 < ActiveRecord::Migration
  def self.up
    add_column :uds_service_identifiers, :data_size, :integer
  end

  def self.down
    remove_column :uds_service_identifiers, :data_size
  end
end

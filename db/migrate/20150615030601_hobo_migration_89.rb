class HoboMigration89 < ActiveRecord::Migration
  def self.up
    add_column :uds_service_identifiers, :generate, :boolean, :default => true
  end

  def self.down
    remove_column :uds_service_identifiers, :generate
  end
end

class AddCustomCodeUds < ActiveRecord::Migration
  def self.up
    add_column :uds_service_identifiers, :custom_code, :text
  end

  def self.down
    remove_column :uds_service_identifiers, :custom_code
  end
end

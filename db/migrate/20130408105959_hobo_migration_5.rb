class HoboMigration5 < ActiveRecord::Migration
  def self.up
    add_column :sub_system_flows, :connector_id, :integer

    add_index :sub_system_flows, [:connector_id]
  end

  def self.down
    remove_column :sub_system_flows, :connector_id

    remove_index :sub_system_flows, :name => :index_sub_system_flows_on_connector_id rescue ActiveRecord::StatementInvalid
  end
end

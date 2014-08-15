class HoboMigration60 < ActiveRecord::Migration
  def self.up
    rename_column :flows, :flow_direction_id, :primary_flow_direction_id

    remove_index :flows, :name => :index_flows_on_flow_direction_id rescue ActiveRecord::StatementInvalid
    add_index :flows, [:primary_flow_direction_id]
  end

  def self.down
    rename_column :flows, :primary_flow_direction_id, :flow_direction_id

    remove_index :flows, :name => :index_flows_on_primary_flow_direction_id rescue ActiveRecord::StatementInvalid
    add_index :flows, [:flow_direction_id]
  end
end

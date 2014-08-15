class HoboMigration59 < ActiveRecord::Migration
  def self.up
    add_column :flows, :flow_direction_id, :integer

    add_index :flows, [:flow_direction_id]
  end

  def self.down
    remove_column :flows, :flow_direction_id

    remove_index :flows, :name => :index_flows_on_flow_direction_id rescue ActiveRecord::StatementInvalid
  end
end

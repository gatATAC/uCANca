class HoboMigration48 < ActiveRecord::Migration
  def self.up
    create_table :flow_directions do |t|
      t.string   :name
      t.text     :description
      t.string   :img
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :sub_system_flows, :flow_direction_id, :integer

    add_index :sub_system_flows, [:flow_direction_id]
  end

  def self.down
    remove_column :sub_system_flows, :flow_direction_id

    drop_table :flow_directions

    remove_index :sub_system_flows, :name => :index_sub_system_flows_on_flow_direction_id rescue ActiveRecord::StatementInvalid
  end
end

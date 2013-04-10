class HoboMigration1 < ActiveRecord::Migration
  def self.up
    create_table :sub_systems do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :flow_types do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :flows do |t|
      t.string   :name
      t.boolean  :outdir
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :flow_type_id
    end
    add_index :flows, [:flow_type_id]

    create_table :sub_system_flows do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :flow_id
      t.integer  :sub_system_id
    end
    add_index :sub_system_flows, [:flow_id]
    add_index :sub_system_flows, [:sub_system_id]
  end

  def self.down
    drop_table :sub_systems
    drop_table :flow_types
    drop_table :flows
    drop_table :sub_system_flows
  end
end

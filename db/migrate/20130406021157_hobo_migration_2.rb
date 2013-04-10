class HoboMigration2 < ActiveRecord::Migration
  def self.up
    create_table :node_edges do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :source_id
      t.integer  :destination_id
    end
    add_index :node_edges, [:source_id]
    add_index :node_edges, [:destination_id]

    add_column :sub_systems, :parent_id, :integer
    add_column :sub_systems, :root_id, :integer

    add_index :sub_systems, [:parent_id]
    add_index :sub_systems, [:root_id]
  end

  def self.down
    remove_column :sub_systems, :parent_id
    remove_column :sub_systems, :root_id

    drop_table :node_edges

    remove_index :sub_systems, :name => :index_sub_systems_on_parent_id rescue ActiveRecord::StatementInvalid
    remove_index :sub_systems, :name => :index_sub_systems_on_root_id rescue ActiveRecord::StatementInvalid
  end
end

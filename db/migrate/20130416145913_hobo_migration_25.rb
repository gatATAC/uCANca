class HoboMigration25 < ActiveRecord::Migration
  def self.up
    create_table :layers do |t|
      t.string   :name
      t.integer  :level
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :sub_systems, :layer_id, :integer

    add_column :project_memberships, :maximum_layer, :integer, :default => 0

    add_index :sub_systems, [:layer_id]
  end

  def self.down
    remove_column :sub_systems, :layer_id

    remove_column :project_memberships, :maximum_layer

    drop_table :layers

    remove_index :sub_systems, :name => :index_sub_systems_on_layer_id rescue ActiveRecord::StatementInvalid
  end
end

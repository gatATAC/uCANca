class HoboMigration4 < ActiveRecord::Migration
  def self.up
    create_table :connectors do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :sub_system_id
    end
    add_index :connectors, [:sub_system_id]
  end

  def self.down
    drop_table :connectors
  end
end

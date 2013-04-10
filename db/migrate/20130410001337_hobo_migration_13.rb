class HoboMigration13 < ActiveRecord::Migration
  def self.up
    create_table :function_sub_systems do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :sub_system_id
      t.integer  :function_id
    end
    add_index :function_sub_systems, [:sub_system_id]
    add_index :function_sub_systems, [:function_id]
  end

  def self.down
    drop_table :function_sub_systems
  end
end

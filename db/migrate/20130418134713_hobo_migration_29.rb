class HoboMigration29 < ActiveRecord::Migration
  def self.up
    create_table :state_machines do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :function_sub_system_id
    end
    add_index :state_machines, [:function_sub_system_id]

    change_column :function_sub_systems, :implementacion, :boolean, :default => :false
  end

  def self.down
    change_column :function_sub_systems, :implementacion, :boolean, :default => false

    drop_table :state_machines
  end
end

class HoboMigration35 < ActiveRecord::Migration
  def self.up
    create_table :state_machine_conditions do |t|
      t.string   :name
      t.text     :description
      t.text     :implementation
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :function_sub_system_id
    end
    add_index :state_machine_conditions, [:function_sub_system_id]
  end

  def self.down
    drop_table :state_machine_conditions
  end
end

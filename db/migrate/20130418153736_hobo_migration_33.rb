class HoboMigration33 < ActiveRecord::Migration
  def self.up
    create_table :state_machine_transitions do |t|
      t.string   :name
      t.text     :description
      t.integer  :priority
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :state_machine_state_id
    end
    add_index :state_machine_transitions, [:state_machine_state_id]
  end

  def self.down
    drop_table :state_machine_transitions
  end
end

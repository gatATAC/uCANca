class HoboMigration37 < ActiveRecord::Migration
  def self.up
    create_table :state_machine_transition_actions do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :state_machine_transition_id
      t.integer  :state_machine_action_id
    end
    add_index :state_machine_transition_actions, [:state_machine_transition_id], :name => 'index_state_machine_transition_actions_on_state_machine_transiti'
    add_index :state_machine_transition_actions, [:state_machine_action_id], :name => 'index_state_machine_transition_actions_on_state_machine_action_i'

    create_table :state_machine_actions do |t|
      t.string   :name
      t.text     :description
      t.text     :implementation
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :function_sub_system_id
    end
    add_index :state_machine_actions, [:function_sub_system_id]
  end

  def self.down
    drop_table :state_machine_transition_actions
    drop_table :state_machine_actions
  end
end

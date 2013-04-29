class HoboMigration41 < ActiveRecord::Migration
  def self.up
    create_table :function_tests do |t|
      t.string   :name
      t.text     :description
      t.text     :stimulus
      t.text     :expected_results
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :function_id
      t.integer  :position
    end
    add_index :function_tests, [:function_id]

    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_action_i rescue ActiveRecord::StatementInvalid
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_transiti rescue ActiveRecord::StatementInvalid
    add_index :state_machine_transition_actions, [:state_machine_transition_id], :name => 'index_state_machine_transition_actions_on_state_machine_transiti'
    add_index :state_machine_transition_actions, [:state_machine_action_id], :name => 'index_state_machine_transition_actions_on_state_machine_action_i'
  end

  def self.down
    drop_table :function_tests

    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_transiti rescue ActiveRecord::StatementInvalid
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_action_i rescue ActiveRecord::StatementInvalid
    add_index :state_machine_transition_actions, [:state_machine_action_id], :name => 'index_state_machine_transition_actions_on_state_machine_action_i'
    add_index :state_machine_transition_actions, [:state_machine_transition_id], :name => 'index_state_machine_transition_actions_on_state_machine_transiti'
  end
end

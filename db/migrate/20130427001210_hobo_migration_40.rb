class HoboMigration40 < ActiveRecord::Migration
  def self.up
    add_column :flows, :alternate_name, :string

    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_action_i rescue ActiveRecord::StatementInvalid
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_transiti rescue ActiveRecord::StatementInvalid
    add_index :state_machine_transition_actions, [:state_machine_transition_id], :name => 'index_state_machine_transition_actions_on_state_machine_transiti'
    add_index :state_machine_transition_actions, [:state_machine_action_id], :name => 'index_state_machine_transition_actions_on_state_machine_action_i'
  end

  def self.down
    remove_column :flows, :alternate_name

    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_transiti rescue ActiveRecord::StatementInvalid
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_action_i rescue ActiveRecord::StatementInvalid
    add_index :state_machine_transition_actions, [:state_machine_action_id], :name => 'index_state_machine_transition_actions_on_state_machine_action_i'
    add_index :state_machine_transition_actions, [:state_machine_transition_id], :name => 'index_state_machine_transition_actions_on_state_machine_transiti'
  end
end

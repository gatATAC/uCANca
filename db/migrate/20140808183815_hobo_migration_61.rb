class HoboMigration61 < ActiveRecord::Migration
  def self.up
    add_column :state_machine_conditions, :short_name, :string

    add_column :sub_systems, :abbrev, :string

    add_column :state_machine_actions, :short_name, :string

    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_action_i rescue ActiveRecord::StatementInvalid
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_transiti rescue ActiveRecord::StatementInvalid
    add_index :state_machine_transition_actions, [:transition_id]
    add_index :state_machine_transition_actions, [:action_id]
  end

  def self.down
    remove_column :state_machine_conditions, :short_name

    remove_column :sub_systems, :abbrev

    remove_column :state_machine_actions, :short_name

    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_transition_id rescue ActiveRecord::StatementInvalid
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_action_id rescue ActiveRecord::StatementInvalid
    add_index :state_machine_transition_actions, [:action_id], :name => 'index_state_machine_transition_actions_on_state_machine_action_i'
    add_index :state_machine_transition_actions, [:transition_id], :name => 'index_state_machine_transition_actions_on_state_machine_transiti'
  end
end

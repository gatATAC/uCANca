class HoboMigration45 < ActiveRecord::Migration

  # Atencion, migracion reconstruida a mano, ya que no funciono inicialmente
  # Despues de hacerla manualmente se ha intentado reconstruir por si el futuro
  # lo requiere, pero no se ha probado.

  def self.up

    rename_column :state_machine_transition_actions, :state_machine_transition_id, :transition_id
    rename_column :state_machine_transition_actions, :state_machine_action_id, :action_id

    add_index :state_machine_transition_actions, [:transition_id]
    add_index :state_machine_transition_actions, [:action_id]
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_action_i rescue ActiveRecord::StatementInvalid
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_state_machine_transiti rescue ActiveRecord::StatementInvalid

  end

  def self.down
    rename_column :state_machine_transition_actions, :transition_id, :state_machine_transition_id
    rename_column :state_machine_transition_actions, :action_id, :state_machine_action_id

    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_transition_id rescue ActiveRecord::StatementInvalid
    remove_index :state_machine_transition_actions, :name => :index_state_machine_transition_actions_on_action_id rescue ActiveRecord::StatementInvalid
    add_index :state_machine_transition_actions, [:state_machine_transition_id], :name => 'index_state_machine_transition_actions_on_state_machine_transiti'
    add_index :state_machine_transition_actions, [:state_machine_action_id], :name => 'index_state_machine_transition_actions_on_state_machine_action_i'

  end
end

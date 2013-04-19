class HoboMigration36 < ActiveRecord::Migration
  def self.up
    add_column :state_machine_transitions, :state_machine_condition_id, :integer

    add_index :state_machine_transitions, [:state_machine_condition_id]
  end

  def self.down
    remove_column :state_machine_transitions, :state_machine_condition_id

    remove_index :state_machine_transitions, :name => :index_state_machine_transitions_on_state_machine_condition_id rescue ActiveRecord::StatementInvalid
  end
end

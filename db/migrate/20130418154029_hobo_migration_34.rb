class HoboMigration34 < ActiveRecord::Migration
  def self.up
    add_column :state_machine_transitions, :destination_state_id, :integer

    add_index :state_machine_transitions, [:destination_state_id]
  end

  def self.down
    remove_column :state_machine_transitions, :destination_state_id

    remove_index :state_machine_transitions, :name => :index_state_machine_transitions_on_destination_state_id rescue ActiveRecord::StatementInvalid
  end
end

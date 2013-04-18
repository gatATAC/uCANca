class HoboMigration32 < ActiveRecord::Migration
  def self.up
    create_table :state_machine_states do |t|
      t.string   :name
      t.text     :description
      t.boolean  :initial
      t.boolean  :final
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :state_machine_id
    end
    add_index :state_machine_states, [:state_machine_id]

    add_column :state_machines, :super_state_id, :integer

    add_index :state_machines, [:super_state_id]
  end

  def self.down
    remove_column :state_machines, :super_state_id

    drop_table :state_machine_states

    remove_index :state_machines, :name => :index_state_machines_on_super_state_id rescue ActiveRecord::StatementInvalid
  end
end

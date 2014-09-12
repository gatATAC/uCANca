class HoboMigration67 < ActiveRecord::Migration
  def self.up
    add_column :faults, :flow_id, :integer

    add_index :faults, [:flow_id]
  end

  def self.down
    remove_column :faults, :flow_id

    remove_index :faults, :name => :index_faults_on_flow_id rescue ActiveRecord::StatementInvalid
  end
end

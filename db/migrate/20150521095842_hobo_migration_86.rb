class HoboMigration86 < ActiveRecord::Migration
  def self.up
    add_column :configuration_switches, :project_id, :integer

    add_index :configuration_switches, [:project_id]
  end

  def self.down
    remove_column :configuration_switches, :project_id

    remove_index :configuration_switches, :name => :index_configuration_switches_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

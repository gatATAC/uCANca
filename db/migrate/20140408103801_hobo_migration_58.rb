class HoboMigration58 < ActiveRecord::Migration
  def self.up
    add_column :fault_rehabilitations, :project_id, :integer

    add_index :fault_rehabilitations, [:project_id]
  end

  def self.down
    remove_column :fault_rehabilitations, :project_id

    remove_index :fault_rehabilitations, :name => :index_fault_rehabilitations_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

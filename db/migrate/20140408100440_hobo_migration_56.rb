class HoboMigration56 < ActiveRecord::Migration
  def self.up
    add_column :fault_preconditions, :project_id, :integer

    add_index :fault_preconditions, [:project_id]
  end

  def self.down
    remove_column :fault_preconditions, :project_id

    remove_index :fault_preconditions, :name => :index_fault_preconditions_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

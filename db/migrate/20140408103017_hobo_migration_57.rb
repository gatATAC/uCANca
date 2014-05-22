class HoboMigration57 < ActiveRecord::Migration
  def self.up
    add_column :fault_recurrence_times, :project_id, :integer

    add_index :fault_recurrence_times, [:project_id]
  end

  def self.down
    remove_column :fault_recurrence_times, :project_id

    remove_index :fault_recurrence_times, :name => :index_fault_recurrence_times_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

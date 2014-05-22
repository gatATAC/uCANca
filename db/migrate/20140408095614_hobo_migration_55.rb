class HoboMigration55 < ActiveRecord::Migration
  def self.up
    add_column :fault_detection_moments, :project_id, :integer

    add_index :fault_detection_moments, [:project_id]
  end

  def self.down
    remove_column :fault_detection_moments, :project_id

    remove_index :fault_detection_moments, :name => :index_fault_detection_moments_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

class HoboMigration42 < ActiveRecord::Migration
  def self.up
    add_column :function_sub_systems, :project_temp_id, :integer

    add_index :function_sub_systems, [:project_temp_id]
  end

  def self.down
    remove_column :function_sub_systems, :project_temp_id

    remove_index :function_sub_systems, :name => :index_function_sub_systems_on_project_temp_id rescue ActiveRecord::StatementInvalid
  end
end

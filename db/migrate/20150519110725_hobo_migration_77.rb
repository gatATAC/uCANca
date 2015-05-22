class HoboMigration77 < ActiveRecord::Migration
  def self.up
    add_column :uds_apps, :project_id, :integer

    add_index :uds_apps, [:project_id]
  end

  def self.down
    remove_column :uds_apps, :project_id

    remove_index :uds_apps, :name => :index_uds_apps_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

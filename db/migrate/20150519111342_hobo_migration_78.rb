class HoboMigration78 < ActiveRecord::Migration
  def self.up
    add_column :uds_security_levels, :project_id, :integer

    add_index :uds_security_levels, [:project_id]
  end

  def self.down
    remove_column :uds_security_levels, :project_id

    remove_index :uds_security_levels, :name => :index_uds_security_levels_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

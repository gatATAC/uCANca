class HoboMigration10 < ActiveRecord::Migration
  def self.up
    add_column :sub_system_flows, :outdir, :boolean
  end

  def self.down
    remove_column :sub_system_flows, :outdir
  end
end

class HoboMigration62 < ActiveRecord::Migration
  def self.up
    remove_column :sub_system_flows, :outdir
  end

  def self.down
    add_column :sub_system_flows, :outdir, :boolean
  end
end

class HoboMigration14 < ActiveRecord::Migration
  def self.up
    remove_column :flows, :outdir
  end

  def self.down
    add_column :flows, :outdir, :boolean
  end
end

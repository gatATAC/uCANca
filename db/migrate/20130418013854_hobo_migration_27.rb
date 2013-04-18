class HoboMigration27 < ActiveRecord::Migration
  def self.up
    add_column :flow_types, :tipo_fantasma, :boolean, :default => false
  end

  def self.down
    remove_column :flow_types, :tipo_fantasma
  end
end

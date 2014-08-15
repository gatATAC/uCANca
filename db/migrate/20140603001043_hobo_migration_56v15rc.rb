class HoboMigration56v15rc < ActiveRecord::Migration
  def self.up
    remove_column :flow_type_targets, :name
  end

  def self.down
    add_column :flow_type_targets, :name, :string
  end
end

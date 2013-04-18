class HoboMigration31 < ActiveRecord::Migration
  def self.up
    add_column :function_sub_systems, :name, :string
  end

  def self.down
    remove_column :function_sub_systems, :name
  end
end

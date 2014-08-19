class HoboMigration40 < ActiveRecord::Migration
  def self.up
    add_column :flows, :alternate_name, :string
  end

  def self.down
    remove_column :flows, :alternate_name
  end
end

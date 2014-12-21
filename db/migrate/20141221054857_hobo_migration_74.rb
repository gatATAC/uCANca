class HoboMigration74 < ActiveRecord::Migration
  def self.up
    remove_column :edi_flows, :color
    remove_column :edi_flows, :prop
  end

  def self.down
    add_column :edi_flows, :color, :integer
    add_column :edi_flows, :prop, :string
  end
end

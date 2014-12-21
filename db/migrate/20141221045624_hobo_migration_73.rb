class HoboMigration73 < ActiveRecord::Migration
  def self.up
    add_column :edi_flows, :pos_x_inner, :integer
    add_column :edi_flows, :pos_y_inner, :integer
    add_column :edi_flows, :pos_x_dataflow, :integer
    add_column :edi_flows, :pos_y_dataflow, :integer
    add_column :edi_flows, :pos_x_inner_dataflow, :integer
    add_column :edi_flows, :pos_y_inner_dataflow, :integer
    add_column :edi_flows, :bidir, :boolean
    remove_column :edi_flows, :attr_name
    remove_column :edi_flows, :attr_value
    remove_column :edi_flows, :attr_type
    remove_column :edi_flows, :edi_type
    remove_column :edi_flows, :internal
  end

  def self.down
    remove_column :edi_flows, :pos_x_inner
    remove_column :edi_flows, :pos_y_inner
    remove_column :edi_flows, :pos_x_dataflow
    remove_column :edi_flows, :pos_y_dataflow
    remove_column :edi_flows, :pos_x_inner_dataflow
    remove_column :edi_flows, :pos_y_inner_dataflow
    remove_column :edi_flows, :bidir
    add_column :edi_flows, :attr_name, :string
    add_column :edi_flows, :attr_value, :string
    add_column :edi_flows, :attr_type, :string
    add_column :edi_flows, :edi_type, :string
    add_column :edi_flows, :internal, :boolean
  end
end

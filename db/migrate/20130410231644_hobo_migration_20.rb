class HoboMigration20 < ActiveRecord::Migration
  def self.up
    add_column :flow_types, :tipo_propio, :boolean, :default => :false
    change_column :flow_types, :enable_input, :boolean, :default => :true
    change_column :flow_types, :enable_output, :boolean, :default => :true
    change_column :flow_types, :paso_por_referencia, :boolean, :default => :false
  end

  def self.down
    remove_column :flow_types, :tipo_propio
    change_column :flow_types, :enable_input, :boolean, :default => true
    change_column :flow_types, :enable_output, :boolean, :default => true
    change_column :flow_types, :paso_por_referencia, :boolean, :default => false
  end
end

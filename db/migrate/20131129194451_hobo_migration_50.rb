class HoboMigration50 < ActiveRecord::Migration
  def self.up
    rename_column :flow_types, :paso_por_referencia, :arg_by_reference
    rename_column :flow_types, :tipo_propio, :custom_type
    rename_column :flow_types, :tipo_fantasma, :phantom_type
  end

  def self.down
    rename_column :flow_types, :arg_by_reference, :paso_por_referencia
    rename_column :flow_types, :custom_type, :tipo_propio
    rename_column :flow_types, :phantom_type, :tipo_fantasma
  end
end

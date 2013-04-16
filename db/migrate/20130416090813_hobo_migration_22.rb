class HoboMigration22 < ActiveRecord::Migration
  def self.up
    add_column :projects, :owner_id, :integer

    change_column :flow_types, :enable_input, :boolean, :default => :true
    change_column :flow_types, :enable_output, :boolean, :default => :true
    change_column :flow_types, :paso_por_referencia, :boolean, :default => :false
    change_column :flow_types, :tipo_propio, :boolean, :default => :false

    add_index :projects, [:owner_id]
  end

  def self.down
    remove_column :projects, :owner_id

    change_column :flow_types, :enable_input, :boolean, :default => true
    change_column :flow_types, :enable_output, :boolean, :default => true
    change_column :flow_types, :paso_por_referencia, :boolean, :default => false
    change_column :flow_types, :tipo_propio, :boolean, :default => false

    remove_index :projects, :name => :index_projects_on_owner_id rescue ActiveRecord::StatementInvalid
  end
end

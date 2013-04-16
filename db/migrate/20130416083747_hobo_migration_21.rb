class HoboMigration21 < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :functions, :project_id, :integer

    add_column :sub_systems, :project_id, :integer

    change_column :flow_types, :enable_input, :boolean, :default => :true
    change_column :flow_types, :enable_output, :boolean, :default => :true
    change_column :flow_types, :paso_por_referencia, :boolean, :default => :false
    change_column :flow_types, :tipo_propio, :boolean, :default => :false

    add_column :flows, :project_id, :integer

    add_index :functions, [:project_id]

    add_index :sub_systems, [:project_id]

    add_index :flows, [:project_id]
  end

  def self.down
    remove_column :functions, :project_id

    remove_column :sub_systems, :project_id

    change_column :flow_types, :enable_input, :boolean, :default => true
    change_column :flow_types, :enable_output, :boolean, :default => true
    change_column :flow_types, :paso_por_referencia, :boolean, :default => false
    change_column :flow_types, :tipo_propio, :boolean, :default => false

    remove_column :flows, :project_id

    drop_table :projects

    remove_index :functions, :name => :index_functions_on_project_id rescue ActiveRecord::StatementInvalid

    remove_index :sub_systems, :name => :index_sub_systems_on_project_id rescue ActiveRecord::StatementInvalid

    remove_index :flows, :name => :index_flows_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

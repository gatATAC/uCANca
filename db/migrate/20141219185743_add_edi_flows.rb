class AddEdiFlows < ActiveRecord::Migration
  def self.up
    create_table :edi_flows do |t|
      t.integer  :ident
      t.string   :label
      t.integer  :color
      t.integer  :pos_x
      t.integer  :pos_y
      t.string   :data_type
      t.string   :prop
      t.string   :attr_name
      t.string   :attr_value
      t.string   :attr_type
      t.integer  :size_x
      t.integer  :size_y
      t.string   :edi_type
      t.boolean  :internal
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :sub_system_flow_id
      t.integer  :edi_process_id
    end
    add_index :edi_flows, [:sub_system_flow_id]
    add_index :edi_flows, [:edi_process_id]

    remove_column :edi_processes, :parent_id

    remove_index :edi_processes, :name => :index_edi_processes_on_parent_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :edi_processes, :parent_id, :integer

    drop_table :edi_flows

    add_index :edi_processes, [:parent_id]
  end
end

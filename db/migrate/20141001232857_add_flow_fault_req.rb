class AddFlowFaultReq < ActiveRecord::Migration
  def self.up
    add_column :fault_requirements, :flow_id, :integer

    add_index :fault_requirements, [:flow_id]
  end

  def self.down
    remove_column :fault_requirements, :flow_id

    remove_index :fault_requirements, :name => :index_fault_requirements_on_flow_id rescue ActiveRecord::StatementInvalid
  end
end

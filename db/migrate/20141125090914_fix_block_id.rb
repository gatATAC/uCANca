class FixBlockId < ActiveRecord::Migration
  def self.up
    add_column :edi_processes, :sub_system_id, :integer
    remove_column :edi_processes, :block_id

    add_index :edi_processes, [:sub_system_id]
  end

  def self.down
    remove_column :edi_processes, :sub_system_id
    add_column :edi_processes, :block_id, :string

    remove_index :edi_processes, :name => :index_edi_processes_on_sub_system_id rescue ActiveRecord::StatementInvalid
  end
end

class HoboMigration9 < ActiveRecord::Migration
  def self.up
    remove_column :sub_system_flows, :sub_system_id

    remove_index :sub_system_flows, :name => :index_sub_system_flows_on_sub_system_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :sub_system_flows, :sub_system_id, :integer

    add_index :sub_system_flows, [:sub_system_id]
  end
end

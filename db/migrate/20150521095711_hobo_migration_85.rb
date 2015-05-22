class HoboMigration85 < ActiveRecord::Migration
  def self.up
    create_table :configuration_switches do |t|
      t.string   :name
      t.string   :ident
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :uds_service_identifiers, :configuration_switch_id, :integer

    add_index :uds_service_identifiers, [:configuration_switch_id]
  end

  def self.down
    remove_column :uds_service_identifiers, :configuration_switch_id

    drop_table :configuration_switches

    remove_index :uds_service_identifiers, :name => :index_uds_service_identifiers_on_configuration_switch_id rescue ActiveRecord::StatementInvalid
  end
end

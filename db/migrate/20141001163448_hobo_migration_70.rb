class HoboMigration70 < ActiveRecord::Migration
  def self.up
    add_column :data, :unit_id, :integer

    add_index :data, [:unit_id]
  end

  def self.down
    remove_column :data, :unit_id

    remove_index :data, :name => :index_data_on_unit_id rescue ActiveRecord::StatementInvalid
  end
end

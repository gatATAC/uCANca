class HoboMigration69 < ActiveRecord::Migration
  def self.up
    add_column :datum_conversions, :project_id, :integer

    add_index :datum_conversions, [:project_id]
  end

  def self.down
    remove_column :datum_conversions, :project_id

    remove_index :datum_conversions, :name => :index_datum_conversions_on_project_id rescue ActiveRecord::StatementInvalid
  end
end

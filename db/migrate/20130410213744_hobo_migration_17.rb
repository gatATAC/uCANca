class HoboMigration17 < ActiveRecord::Migration
  def self.up
    change_column :flow_types, :c_input_patron, :text, :limit => nil
    change_column :flow_types, :c_output_patron, :text, :limit => nil
  end

  def self.down
    change_column :flow_types, :c_input_patron, :string
    change_column :flow_types, :c_output_patron, :string
  end
end

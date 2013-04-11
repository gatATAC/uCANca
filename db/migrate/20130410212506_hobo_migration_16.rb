class HoboMigration16 < ActiveRecord::Migration
  def self.up
    add_column :flow_types, :c_input_patron, :string
    add_column :flow_types, :c_output_patron, :string
  end

  def self.down
    remove_column :flow_types, :c_input_patron
    remove_column :flow_types, :c_output_patron
  end
end

class HoboMigration55v15rc < ActiveRecord::Migration
  def self.up
    rename_column :flow_type_targets, :c_setup_patron, :c_setup_input_patron
    add_column :flow_type_targets, :c_setup_output_patron, :text

    rename_column :flow_types, :c_setup_patron, :c_setup_input_patron
    add_column :flow_types, :c_setup_output_patron, :text
  end

  def self.down
    rename_column :flow_type_targets, :c_setup_input_patron, :c_setup_patron
    remove_column :flow_type_targets, :c_setup_output_patron

    rename_column :flow_types, :c_setup_input_patron, :c_setup_patron
    remove_column :flow_types, :c_setup_output_patron
  end
end

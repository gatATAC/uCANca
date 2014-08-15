class HoboMigration54v15rc < ActiveRecord::Migration
  def self.up
    add_column :flow_type_targets, :c_setup_patron, :text

    add_column :flow_types, :c_setup_patron, :text
  end

  def self.down
    remove_column :flow_type_targets, :c_setup_patron

    remove_column :flow_types, :c_setup_patron
  end
end

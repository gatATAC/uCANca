class HoboMigration53v15Rc < ActiveRecord::Migration
  def self.up
    create_table :flow_type_targets do |t|
      t.string   :name
      t.string   :c_type
      t.text     :c_input_patron
      t.text     :c_output_patron
      t.boolean  :enable_input, :default => true
      t.boolean  :enable_output, :default => true
      t.boolean  :arg_by_reference, :default => false
      t.boolean  :custom_type, :default => false
      t.boolean  :phantom_type, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :flow_type_id
      t.integer  :target_id
    end
    add_index :flow_type_targets, [:flow_type_id]
    add_index :flow_type_targets, [:target_id]
  end

  def self.down
    drop_table :flow_type_targets
  end
end

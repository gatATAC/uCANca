class HoboMigration68 < ActiveRecord::Migration
  def self.up
    create_table :datum_conversions do |t|
      t.string   :name
      t.boolean  :convert
      t.boolean  :truncate
      t.float    :factor
      t.float    :offset
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :flow_type_id
    end
    add_index :datum_conversions, [:flow_type_id]

    create_table :conversion_targets do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :data do |t|
      t.string   :name
      t.text     :description
      t.float    :min_phys_value
      t.float    :max_phys_value
      t.float    :typ_phys_value
      t.text     :comment
      t.boolean  :generate
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :flow_id
    end
    add_index :data, [:flow_id]

    create_table :units do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :datum_datum_conversions do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :datum_id
      t.integer  :datum_conversion_id
      t.integer  :conversion_target_id
    end
    add_index :datum_datum_conversions, [:datum_id]
    add_index :datum_datum_conversions, [:datum_conversion_id]
    add_index :datum_datum_conversions, [:conversion_target_id]

    add_column :flow_types, :size, :integer
    add_column :flow_types, :A2l_type, :string
    add_column :flow_types, :dataset_type, :string
    add_column :flow_types, :parameter_set_type, :string
    add_column :flow_types, :is_float, :boolean
    add_column :flow_types, :is_symbol, :boolean
    add_column :flow_types, :A2L_symbol_code, :text
  end

  def self.down
    remove_column :flow_types, :size
    remove_column :flow_types, :A2l_type
    remove_column :flow_types, :dataset_type
    remove_column :flow_types, :parameter_set_type
    remove_column :flow_types, :is_float
    remove_column :flow_types, :is_symbol
    remove_column :flow_types, :A2L_symbol_code

    drop_table :datum_conversions
    drop_table :conversion_targets
    drop_table :data
    drop_table :units
    drop_table :datum_datum_conversions
  end
end

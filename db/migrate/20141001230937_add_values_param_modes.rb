class AddValuesParamModes < ActiveRecord::Migration
  def self.up
    create_table :values do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :parameters do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :sub_system_id
    end
    add_index :parameters, [:sub_system_id]

    create_table :modes do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :sub_system_id
    end
    add_index :modes, [:sub_system_id]
  end

  def self.down
    drop_table :values
    drop_table :parameters
    drop_table :modes
  end
end

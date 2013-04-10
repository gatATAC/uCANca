class HoboMigration11 < ActiveRecord::Migration
  def self.up
    create_table :functions do |t|
      t.string   :ident
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :function_types do |t|
      t.string   :name
      t.text     :description
      t.float    :estimated_days
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :functions
    drop_table :function_types
  end
end

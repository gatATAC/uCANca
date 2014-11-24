class HoboMigration72 < ActiveRecord::Migration
  def self.up
    create_table :edi_models do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :project_id
    end
    add_index :edi_models, [:project_id]
  end

  def self.down
    drop_table :edi_models
  end
end

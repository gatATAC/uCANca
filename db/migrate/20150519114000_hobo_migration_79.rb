class HoboMigration79 < ActiveRecord::Migration
  def self.up
    drop_table :uds_adressings

    create_table :uds_addressings do |t|
      t.string   :ident
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    create_table "uds_adressings", :force => true do |t|
      t.string   "ident"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    drop_table :uds_addressings
  end
end

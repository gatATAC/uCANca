class HoboMigration84 < ActiveRecord::Migration
  def self.up
    create_table :uds_response_codes do |t|
      t.string   :ident
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :uds_response_codes
  end
end

class HoboMigration41 < ActiveRecord::Migration
  def self.up
    create_table :function_tests do |t|
      t.string   :name
      t.text     :description
      t.text     :stimulus
      t.text     :expected_results
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :function_id
      t.integer  :position
    end
    add_index :function_tests, [:function_id]
  end

  def self.down
    drop_table :function_tests
  end
end

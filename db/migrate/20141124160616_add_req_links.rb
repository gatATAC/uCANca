class AddReqLinks < ActiveRecord::Migration
  def self.up
    create_table :req_links do |t|
      t.boolean  :is_external
      t.string   :ext_url
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :requirement_id
      t.integer  :req_source_id
    end
    add_index :req_links, [:requirement_id]
    add_index :req_links, [:req_source_id]
  end

  def self.down
    drop_table :req_links
  end
end

class AddReqDocs < ActiveRecord::Migration
  def self.up
    create_table :req_docs do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :project_id
      t.integer  :req_doc_type_id
    end
    add_index :req_docs, [:project_id]
    add_index :req_docs, [:req_doc_type_id]

    create_table :req_doc_types do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :flows, :datum_conversion_id, :integer

    add_column :datum_conversions, :flow_id, :integer

    add_index :flows, [:datum_conversion_id]

    add_index :datum_conversions, [:flow_id]
    
    ReqDocType.create :name=>"Global Requirements", :abbrev => "SR"
    ReqDocType.create :name=>"System Architecture", :abbrev => "SA"    
    
  end

  def self.down
    remove_column :flows, :datum_conversion_id

    remove_column :datum_conversions, :flow_id

    drop_table :req_docs
    drop_table :req_doc_types

    remove_index :flows, :name => :index_flows_on_datum_conversion_id rescue ActiveRecord::StatementInvalid

    remove_index :datum_conversions, :name => :index_datum_conversions_on_flow_id rescue ActiveRecord::StatementInvalid
  end
end

class HoboMigration71 < ActiveRecord::Migration
  def self.up
    create_table :sw_req_types do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :req_target_micros do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :requirements do |t|
      t.string   :object_identifier
      t.integer  :object_level
      t.integer  :absolute_number
      t.boolean  :is_a_req
      t.boolean  :is_implemented
      t.string   :created_by
      t.date     :created_on
      t.string   :customer_req_accept_comments
      t.boolean  :customer_req_accepted
      t.string   :last_modified_by
      t.string   :master_req_acceptance_comments
      t.string   :object_heading
      t.string   :object_short_text
      t.string   :object_text
      t.string   :priority
      t.boolean  :is_real_time
      t.string   :req_source
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :req_doc_id
      t.integer  :req_criticality_id
      t.integer  :req_target_micro_id
      t.integer  :req_type_id
      t.integer  :sw_req_type_id
    end
    add_index :requirements, [:req_doc_id]
    add_index :requirements, [:req_criticality_id]
    add_index :requirements, [:req_target_micro_id]
    add_index :requirements, [:req_type_id]
    add_index :requirements, [:sw_req_type_id]

    create_table :req_criticalities do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :req_types do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
    end

    ReqType.create :name => "Information", :abbrev => "Info"
    ReqType.create :name => "Complex", :abbrev => "Complex"
    ReqType.create :name => "Mechanical", :abbrev => "Info"
    ReqType.create :name => "Hardware", :abbrev => "Hw"
    ReqType.create :name => "Software", :abbrev => "Sw"

    SwReqType.create :name => "No software related", :abbrev => "No Sw related"
    SwReqType.create :name => "Information", :abbrev => "Sw Info"
    SwReqType.create :name => "Software System", :abbrev => "Sw system"
    SwReqType.create :name => "Software Derivated", :abbrev => "Sw derivated"
    
    ReqCriticality.create :name => "Not evaluated", :abbrev => "Not evaluated"
    ReqCriticality.create :name => "Low", :abbrev => "Low"
    ReqCriticality.create :name => "Medium", :abbrev => "Medium"
    ReqCriticality.create :name => "High", :abbrev => "High"
    
  end

  def self.down
    drop_table :sw_req_types
    drop_table :req_target_micros
    drop_table :requirements
    drop_table :req_criticalities
    drop_table :req_types
  end
end

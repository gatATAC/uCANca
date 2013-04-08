# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130408140055) do

  create_table "connectors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_system_id"
    t.integer  "position"
  end

  add_index "connectors", ["sub_system_id"], :name => "index_connectors_on_sub_system_id"

  create_table "flow_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flows", :force => true do |t|
    t.string   "name"
    t.boolean  "outdir"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_type_id"
  end

  add_index "flows", ["flow_type_id"], :name => "index_flows_on_flow_type_id"

  create_table "node_edges", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.integer  "destination_id"
    t.integer  "position"
  end

  add_index "node_edges", ["destination_id"], :name => "index_node_edges_on_destination_id"
  add_index "node_edges", ["source_id"], :name => "index_node_edges_on_source_id"

  create_table "sub_system_flows", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_id"
    t.integer  "sub_system_id"
    t.integer  "connector_id"
    t.integer  "position"
  end

  add_index "sub_system_flows", ["connector_id"], :name => "index_sub_system_flows_on_connector_id"
  add_index "sub_system_flows", ["flow_id"], :name => "index_sub_system_flows_on_flow_id"
  add_index "sub_system_flows", ["sub_system_id"], :name => "index_sub_system_flows_on_sub_system_id"

  create_table "sub_systems", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "root_id"
    t.integer  "position"
  end

  add_index "sub_systems", ["parent_id"], :name => "index_sub_systems_on_parent_id"
  add_index "sub_systems", ["root_id"], :name => "index_sub_systems_on_root_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "inactive"
    t.datetime "key_timestamp"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end

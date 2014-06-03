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

ActiveRecord::Schema.define(:version => 20140603001043) do

  create_table "connectors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_system_id"
    t.integer  "position"
  end

  add_index "connectors", ["sub_system_id"], :name => "index_connectors_on_sub_system_id"

  create_table "flow_directions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "img"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flow_type_targets", :force => true do |t|
    t.string   "c_type"
    t.text     "c_input_patron"
    t.text     "c_output_patron"
    t.boolean  "enable_input",          :default => true
    t.boolean  "enable_output",         :default => true
    t.boolean  "arg_by_reference",      :default => false
    t.boolean  "custom_type",           :default => false
    t.boolean  "phantom_type",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_type_id"
    t.integer  "target_id"
    t.text     "c_setup_input_patron"
    t.text     "c_setup_output_patron"
  end

  add_index "flow_type_targets", ["flow_type_id"], :name => "index_flow_type_targets_on_flow_type_id"
  add_index "flow_type_targets", ["target_id"], :name => "index_flow_type_targets_on_target_id"

  create_table "flow_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "c_type"
    t.text     "c_input_patron"
    t.text     "c_output_patron"
    t.boolean  "enable_input",          :default => true
    t.boolean  "enable_output",         :default => true
    t.boolean  "arg_by_reference",      :default => false
    t.boolean  "custom_type",           :default => false
    t.boolean  "phantom_type",          :default => false
    t.text     "c_setup_input_patron"
    t.text     "c_setup_output_patron"
  end

  create_table "flows", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_type_id"
    t.integer  "project_id"
    t.boolean  "puntero",        :default => false
    t.string   "alternate_name"
  end

  add_index "flows", ["flow_type_id"], :name => "index_flows_on_flow_type_id"
  add_index "flows", ["project_id"], :name => "index_flows_on_project_id"

  create_table "function_sub_systems", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_system_id"
    t.integer  "function_id"
    t.integer  "position"
    t.boolean  "implementacion", :default => false
    t.string   "name"
  end

  add_index "function_sub_systems", ["function_id"], :name => "index_function_sub_systems_on_function_id"
  add_index "function_sub_systems", ["sub_system_id"], :name => "index_function_sub_systems_on_sub_system_id"

  create_table "function_tests", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "stimulus"
    t.text     "expected_results"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "function_id"
    t.integer  "position"
  end

  add_index "function_tests", ["function_id"], :name => "index_function_tests_on_function_id"

  create_table "function_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "estimated_days"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "functions", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "function_type_id"
    t.integer  "project_id"
  end

  add_index "functions", ["function_type_id"], :name => "index_functions_on_function_type_id"
  add_index "functions", ["project_id"], :name => "index_functions_on_project_id"

  create_table "layers", :force => true do |t|
    t.string   "name"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "node_edges", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.integer  "destination_id"
    t.integer  "position"
  end

  add_index "node_edges", ["destination_id"], :name => "index_node_edges_on_destination_id"
  add_index "node_edges", ["source_id"], :name => "index_node_edges_on_source_id"

  create_table "project_memberships", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
    t.boolean  "contributor",   :default => false
    t.integer  "maximum_layer", :default => 0
  end

  add_index "project_memberships", ["project_id"], :name => "index_project_memberships_on_project_id"
  add_index "project_memberships", ["user_id"], :name => "index_project_memberships_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.boolean  "public"
    t.text     "description"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "target_id"
  end

  add_index "projects", ["owner_id"], :name => "index_projects_on_owner_id"
  add_index "projects", ["target_id"], :name => "index_projects_on_target_id"

  create_table "st_mach_sys_maps", :force => true do |t|
    t.boolean  "implementation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state_machine_id"
    t.integer  "sub_system_id"
  end

  add_index "st_mach_sys_maps", ["state_machine_id"], :name => "index_st_mach_sys_maps_on_state_machine_id"
  add_index "st_mach_sys_maps", ["sub_system_id"], :name => "index_st_mach_sys_maps_on_sub_system_id"

  create_table "state_machine_actions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "implementation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "function_sub_system_id"
    t.string   "short_name"
  end

  add_index "state_machine_actions", ["function_sub_system_id"], :name => "index_state_machine_actions_on_function_sub_system_id"

  create_table "state_machine_conditions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "implementation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "function_sub_system_id"
    t.string   "short_name"
  end

  add_index "state_machine_conditions", ["function_sub_system_id"], :name => "index_state_machine_conditions_on_function_sub_system_id"

  create_table "state_machine_states", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "initial"
    t.boolean  "final"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state_machine_id"
  end

  add_index "state_machine_states", ["state_machine_id"], :name => "index_state_machine_states_on_state_machine_id"

  create_table "state_machine_transition_actions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "transition_id"
    t.integer  "action_id"
  end

  add_index "state_machine_transition_actions", ["action_id"], :name => "index_state_machine_transition_actions_on_action_id"
  add_index "state_machine_transition_actions", ["transition_id"], :name => "index_state_machine_transition_actions_on_transition_id"

  create_table "state_machine_transitions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state_machine_state_id"
    t.integer  "destination_state_id"
    t.integer  "state_machine_condition_id"
  end

  add_index "state_machine_transitions", ["destination_state_id"], :name => "index_state_machine_transitions_on_destination_state_id"
  add_index "state_machine_transitions", ["state_machine_condition_id"], :name => "index_state_machine_transitions_on_state_machine_condition_id"
  add_index "state_machine_transitions", ["state_machine_state_id"], :name => "index_state_machine_transitions_on_state_machine_state_id"

  create_table "state_machines", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "function_sub_system_id"
    t.integer  "super_state_id"
    t.string   "graphviz_link",          :default => "?cht=gv:neato&amp;chl=digraph{edge[fontsize=7];fontsize=11;nodesep=1;ranksep=1;sep=3;overlap=scale;"
    t.string   "graphviz_size",          :default => "&amp;chs=500x500"
  end

  add_index "state_machines", ["function_sub_system_id"], :name => "index_state_machines_on_function_sub_system_id"
  add_index "state_machines", ["super_state_id"], :name => "index_state_machines_on_super_state_id"

  create_table "sub_system_flows", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_id"
    t.integer  "connector_id"
    t.integer  "position"
    t.boolean  "outdir"
    t.integer  "flow_direction_id"
  end

  add_index "sub_system_flows", ["connector_id"], :name => "index_sub_system_flows_on_connector_id"
  add_index "sub_system_flows", ["flow_direction_id"], :name => "index_sub_system_flows_on_flow_direction_id"
  add_index "sub_system_flows", ["flow_id"], :name => "index_sub_system_flows_on_flow_id"

  create_table "sub_systems", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "root_id"
    t.integer  "position"
    t.integer  "project_id"
    t.integer  "layer_id"
    t.string   "abbrev"
    t.integer  "target_id"
  end

  add_index "sub_systems", ["layer_id"], :name => "index_sub_systems_on_layer_id"
  add_index "sub_systems", ["parent_id"], :name => "index_sub_systems_on_parent_id"
  add_index "sub_systems", ["project_id"], :name => "index_sub_systems_on_project_id"
  add_index "sub_systems", ["root_id"], :name => "index_sub_systems_on_root_id"
  add_index "sub_systems", ["target_id"], :name => "index_sub_systems_on_target_id"

  create_table "targets", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.boolean  "developer",                               :default => false
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end

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

ActiveRecord::Schema.define(:version => 20150616125235) do

  create_table "configuration_switches", :force => true do |t|
    t.string   "name"
    t.string   "ident"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "configuration_switches", ["project_id"], :name => "index_configuration_switches_on_project_id"

  create_table "connectors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_system_id"
    t.integer  "position"
  end

  add_index "connectors", ["sub_system_id"], :name => "index_connectors_on_sub_system_id"

  create_table "conversion_targets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "min_phys_value"
    t.float    "max_phys_value"
    t.float    "typ_phys_value"
    t.text     "comment"
    t.boolean  "generate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_id"
    t.integer  "unit_id"
  end

  add_index "data", ["flow_id"], :name => "index_data_on_flow_id"
  add_index "data", ["unit_id"], :name => "index_data_on_unit_id"

  create_table "datum_conversions", :force => true do |t|
    t.string   "name"
    t.boolean  "convert"
    t.boolean  "truncate"
    t.float    "factor"
    t.float    "offset"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_type_id"
    t.integer  "project_id"
    t.integer  "flow_id"
  end

  add_index "datum_conversions", ["flow_id"], :name => "index_datum_conversions_on_flow_id"
  add_index "datum_conversions", ["flow_type_id"], :name => "index_datum_conversions_on_flow_type_id"
  add_index "datum_conversions", ["project_id"], :name => "index_datum_conversions_on_project_id"

  create_table "datum_datum_conversions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "datum_id"
    t.integer  "datum_conversion_id"
    t.integer  "conversion_target_id"
  end

  add_index "datum_datum_conversions", ["conversion_target_id"], :name => "index_datum_datum_conversions_on_conversion_target_id"
  add_index "datum_datum_conversions", ["datum_conversion_id"], :name => "index_datum_datum_conversions_on_datum_conversion_id"
  add_index "datum_datum_conversions", ["datum_id"], :name => "index_datum_datum_conversions_on_datum_id"

  create_table "edi_flows", :force => true do |t|
    t.integer  "ident"
    t.string   "label"
    t.integer  "pos_x"
    t.integer  "pos_y"
    t.string   "data_type"
    t.integer  "size_x"
    t.integer  "size_y"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_system_flow_id"
    t.integer  "edi_process_id"
    t.integer  "pos_x_inner"
    t.integer  "pos_y_inner"
    t.integer  "pos_x_dataflow"
    t.integer  "pos_y_dataflow"
    t.integer  "pos_x_inner_dataflow"
    t.integer  "pos_y_inner_dataflow"
    t.boolean  "bidir"
  end

  add_index "edi_flows", ["edi_process_id"], :name => "index_edi_flows_on_edi_process_id"
  add_index "edi_flows", ["sub_system_flow_id"], :name => "index_edi_flows_on_sub_system_flow_id"

  create_table "edi_models", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "xdi_file_name"
    t.string   "xdi_content_type"
    t.integer  "xdi_file_size"
    t.datetime "xdi_updated_at"
  end

  add_index "edi_models", ["project_id"], :name => "index_edi_models_on_project_id"

  create_table "edi_processes", :force => true do |t|
    t.integer  "ident"
    t.string   "label"
    t.integer  "pos_x"
    t.integer  "pos_y"
    t.integer  "size_x"
    t.integer  "size_y"
    t.boolean  "master"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "edi_model_id"
    t.integer  "sub_system_id"
  end

  add_index "edi_processes", ["edi_model_id"], :name => "index_edi_processes_on_edi_model_id"
  add_index "edi_processes", ["sub_system_id"], :name => "index_edi_processes_on_sub_system_id"

  create_table "fail_safe_command_times", :force => true do |t|
    t.string   "name"
    t.integer  "ms"
    t.boolean  "feedback_required", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "fail_safe_command_times", ["project_id"], :name => "index_fail_safe_command_times_on_project_id"

  create_table "fail_safe_commands", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "feedback_required", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "fail_safe_commands", ["project_id"], :name => "index_fail_safe_commands_on_project_id"

  create_table "fault_detection_moments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "code"
    t.boolean  "feedback_required", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "fault_detection_moments", ["project_id"], :name => "index_fault_detection_moments_on_project_id"

  create_table "fault_fail_safe_commands", :force => true do |t|
    t.boolean  "feedback_required",         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fail_safe_command_id"
    t.integer  "fault_id"
    t.integer  "fail_safe_command_time_id"
  end

  add_index "fault_fail_safe_commands", ["fail_safe_command_id"], :name => "index_fault_fail_safe_commands_on_fail_safe_command_id"
  add_index "fault_fail_safe_commands", ["fail_safe_command_time_id"], :name => "index_fault_fail_safe_commands_on_fail_safe_command_time_id"
  add_index "fault_fail_safe_commands", ["fault_id"], :name => "index_fault_fail_safe_commands_on_fault_id"

  create_table "fault_preconditions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "code"
    t.boolean  "feedback_required", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "fault_preconditions", ["project_id"], :name => "index_fault_preconditions_on_project_id"

  create_table "fault_recurrence_times", :force => true do |t|
    t.string   "name"
    t.integer  "ms"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "fault_recurrence_times", ["project_id"], :name => "index_fault_recurrence_times_on_project_id"

  create_table "fault_rehabilitations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "code"
    t.boolean  "feedback_required", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "fault_rehabilitations", ["project_id"], :name => "index_fault_rehabilitations_on_project_id"

  create_table "fault_requirements", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.string   "abbrev_c"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "flow_id"
  end

  add_index "fault_requirements", ["flow_id"], :name => "index_fault_requirements_on_flow_id"
  add_index "fault_requirements", ["project_id"], :name => "index_fault_requirements_on_project_id"

  create_table "faults", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.string   "abbrev_c"
    t.text     "description"
    t.string   "status_byte"
    t.string   "dtc"
    t.string   "dtc_prefix",                         :default => "P"
    t.text     "custom_detection_moment"
    t.text     "custom_precondition"
    t.text     "detection_condition"
    t.string   "qualification_time"
    t.text     "recovery_condition"
    t.string   "recovery_time"
    t.text     "custom_rehabilitation"
    t.boolean  "feedback_required",                  :default => true
    t.boolean  "generate_can",                       :default => true
    t.string   "can_abbrev"
    t.boolean  "activate_value",                     :default => true
    t.boolean  "include_fault",                      :default => true
    t.text     "error_detection_task"
    t.text     "error_detection_task_init"
    t.text     "recovery_detection_task"
    t.text     "recovery_detection_task_init"
    t.text     "rehabilitation_detection_task"
    t.text     "rehabilitation_detection_task_init"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fault_requirement_id"
    t.integer  "fault_precondition_id"
    t.integer  "fault_detection_moment_id"
    t.integer  "fault_recurrence_time_id"
    t.integer  "fault_rehabilitation_id"
    t.string   "failure_flag"
    t.string   "test_completed_flag"
    t.string   "diag_activate_flag"
    t.integer  "flow_id"
  end

  add_index "faults", ["fault_detection_moment_id"], :name => "index_faults_on_fault_detection_moment_id"
  add_index "faults", ["fault_precondition_id"], :name => "index_faults_on_fault_precondition_id"
  add_index "faults", ["fault_recurrence_time_id"], :name => "index_faults_on_fault_recurrence_time_id"
  add_index "faults", ["fault_rehabilitation_id"], :name => "index_faults_on_fault_rehabilitation_id"
  add_index "faults", ["fault_requirement_id"], :name => "index_faults_on_fault_requirement_id"
  add_index "faults", ["flow_id"], :name => "index_faults_on_flow_id"

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
    t.integer  "size"
    t.string   "A2l_type"
    t.string   "dataset_type"
    t.string   "parameter_set_type"
    t.boolean  "is_float"
    t.boolean  "is_symbol"
    t.text     "A2L_symbol_code"
  end

  create_table "flows", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flow_type_id"
    t.integer  "project_id"
    t.boolean  "puntero",                   :default => false
    t.string   "alternate_name"
    t.integer  "primary_flow_direction_id"
    t.integer  "datum_conversion_id"
  end

  add_index "flows", ["datum_conversion_id"], :name => "index_flows_on_datum_conversion_id"
  add_index "flows", ["flow_type_id"], :name => "index_flows_on_flow_type_id"
  add_index "flows", ["primary_flow_direction_id"], :name => "index_flows_on_primary_flow_direction_id"
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

  create_table "modes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_system_id"
  end

  add_index "modes", ["sub_system_id"], :name => "index_modes_on_sub_system_id"

  create_table "node_edges", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.integer  "destination_id"
    t.integer  "position"
  end

  add_index "node_edges", ["destination_id"], :name => "index_node_edges_on_destination_id"
  add_index "node_edges", ["source_id"], :name => "index_node_edges_on_source_id"

  create_table "parameters", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sub_system_id"
  end

  add_index "parameters", ["sub_system_id"], :name => "index_parameters_on_sub_system_id"

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
    t.string   "abbrev"
  end

  add_index "projects", ["owner_id"], :name => "index_projects_on_owner_id"
  add_index "projects", ["target_id"], :name => "index_projects_on_target_id"

  create_table "req_created_throughs", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "req_criticalities", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "req_doc_types", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "req_docs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "req_doc_type_id"
  end

  add_index "req_docs", ["project_id"], :name => "index_req_docs_on_project_id"
  add_index "req_docs", ["req_doc_type_id"], :name => "index_req_docs_on_req_doc_type_id"

  create_table "req_links", :force => true do |t|
    t.boolean  "is_external"
    t.string   "ext_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "requirement_id"
    t.integer  "req_source_id"
  end

  add_index "req_links", ["req_source_id"], :name => "index_req_links_on_req_source_id"
  add_index "req_links", ["requirement_id"], :name => "index_req_links_on_requirement_id"

  create_table "req_target_micros", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "req_types", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requirements", :force => true do |t|
    t.string   "object_identifier"
    t.integer  "object_level"
    t.integer  "absolute_number"
    t.boolean  "is_a_req"
    t.boolean  "is_implemented"
    t.string   "created_by"
    t.date     "created_on"
    t.string   "customer_req_accept_comments"
    t.boolean  "customer_req_accepted"
    t.string   "last_modified_by"
    t.string   "master_req_acceptance_comments"
    t.string   "object_heading"
    t.string   "object_short_text"
    t.text     "object_text"
    t.string   "priority"
    t.boolean  "is_real_time"
    t.string   "req_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "req_doc_id"
    t.integer  "req_criticality_id"
    t.integer  "req_target_micro_id"
    t.integer  "req_type_id"
    t.integer  "sw_req_type_id"
    t.integer  "req_created_through_id"
    t.string   "object_number"
    t.date     "last_modified_on"
    t.boolean  "master_req_accepted"
  end

  add_index "requirements", ["req_created_through_id"], :name => "index_requirements_on_req_created_through_id"
  add_index "requirements", ["req_criticality_id"], :name => "index_requirements_on_req_criticality_id"
  add_index "requirements", ["req_doc_id"], :name => "index_requirements_on_req_doc_id"
  add_index "requirements", ["req_target_micro_id"], :name => "index_requirements_on_req_target_micro_id"
  add_index "requirements", ["req_type_id"], :name => "index_requirements_on_req_type_id"
  add_index "requirements", ["sw_req_type_id"], :name => "index_requirements_on_sw_req_type_id"

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
    t.integer  "flow_direction_id"
    t.string   "context_name"
  end

  add_index "sub_system_flows", ["connector_id"], :name => "index_sub_system_flows_on_connector_id"
  add_index "sub_system_flows", ["flow_direction_id"], :name => "index_sub_system_flows_on_flow_direction_id"
  add_index "sub_system_flows", ["flow_id"], :name => "index_sub_system_flows_on_flow_id"

  create_table "sub_system_types", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "sub_system_type_id"
  end

  add_index "sub_systems", ["layer_id"], :name => "index_sub_systems_on_layer_id"
  add_index "sub_systems", ["parent_id"], :name => "index_sub_systems_on_parent_id"
  add_index "sub_systems", ["project_id"], :name => "index_sub_systems_on_project_id"
  add_index "sub_systems", ["root_id"], :name => "index_sub_systems_on_root_id"
  add_index "sub_systems", ["sub_system_type_id"], :name => "index_sub_systems_on_sub_system_type_id"
  add_index "sub_systems", ["target_id"], :name => "index_sub_systems_on_target_id"

  create_table "sw_req_types", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "targets", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uds_addressings", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uds_apps", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "uds_apps", ["project_id"], :name => "index_uds_apps_on_project_id"

  create_table "uds_response_codes", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uds_security_levels", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "uds_security_levels", ["project_id"], :name => "index_uds_security_levels_on_project_id"

  create_table "uds_service_fixed_params", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.integer  "length"
    t.boolean  "app_session_default"
    t.boolean  "app_session_prog"
    t.boolean  "app_session_extended"
    t.boolean  "app_session_supplier"
    t.boolean  "boot_session_default"
    t.boolean  "boot_session_prog"
    t.boolean  "boot_session_extended"
    t.boolean  "boot_session_supplier"
    t.boolean  "sec_locked"
    t.boolean  "sec_lev1"
    t.boolean  "sec_lev_11"
    t.boolean  "sec_supplier"
    t.boolean  "addr_phys"
    t.boolean  "addr_func"
    t.boolean  "supress_bit"
    t.boolean  "precondition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "uds_sub_service_id"
    t.integer  "uds_service_id"
    t.integer  "configuration_switch_id"
    t.text     "custom_code"
    t.boolean  "generate"
  end

  add_index "uds_service_fixed_params", ["configuration_switch_id"], :name => "index_uds_service_fixed_params_on_configuration_switch_id"
  add_index "uds_service_fixed_params", ["uds_service_id"], :name => "index_uds_service_fixed_params_on_uds_service_id"
  add_index "uds_service_fixed_params", ["uds_sub_service_id"], :name => "index_uds_service_fixed_params_on_uds_sub_service_id"

  create_table "uds_service_identifiers", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.integer  "length"
    t.boolean  "app_session_default"
    t.boolean  "app_session_prog"
    t.boolean  "app_session_extended"
    t.boolean  "app_session_supplier"
    t.boolean  "boot_session_default"
    t.boolean  "boot_session_prog"
    t.boolean  "boot_session_extended"
    t.boolean  "boot_session_supplier"
    t.boolean  "sec_locked"
    t.boolean  "sec_lev1"
    t.boolean  "sec_lev_11"
    t.boolean  "sec_supplier"
    t.boolean  "addr_phys"
    t.boolean  "addr_func"
    t.boolean  "supress_bit"
    t.boolean  "precondition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "uds_sub_service_id"
    t.integer  "uds_service_id"
    t.integer  "configuration_switch_id"
    t.integer  "data_size"
    t.text     "custom_code"
    t.boolean  "generate",                :default => true
  end

  add_index "uds_service_identifiers", ["configuration_switch_id"], :name => "index_uds_service_identifiers_on_configuration_switch_id"
  add_index "uds_service_identifiers", ["uds_service_id"], :name => "index_uds_service_identifiers_on_uds_service_id"
  add_index "uds_service_identifiers", ["uds_sub_service_id"], :name => "index_uds_service_identifiers_on_uds_sub_service_id"

  create_table "uds_service_managers", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "uds_service_managers", ["project_id"], :name => "index_uds_service_managers_on_project_id"

  create_table "uds_services", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.integer  "length"
    t.boolean  "app_session_default"
    t.boolean  "app_session_prog"
    t.boolean  "app_session_extended"
    t.boolean  "app_session_supplier"
    t.boolean  "boot_session_default"
    t.boolean  "boot_session_prog"
    t.boolean  "boot_session_extended"
    t.boolean  "boot_session_supplier"
    t.boolean  "sec_locked"
    t.boolean  "sec_lev1"
    t.boolean  "sec_lev_11"
    t.boolean  "sec_supplier"
    t.boolean  "addr_phys"
    t.boolean  "addr_func"
    t.boolean  "supress_bit"
    t.boolean  "precondition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "configuration_switch_id"
    t.text     "custom_code"
    t.boolean  "generate",                :default => true
  end

  add_index "uds_services", ["configuration_switch_id"], :name => "index_uds_services_on_configuration_switch_id"
  add_index "uds_services", ["project_id"], :name => "index_uds_services_on_project_id"

  create_table "uds_sessions", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.string   "sub_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "uds_sessions", ["project_id"], :name => "index_uds_sessions_on_project_id"

  create_table "uds_sub_services", :force => true do |t|
    t.string   "ident"
    t.string   "name"
    t.integer  "length"
    t.boolean  "app_session_default"
    t.boolean  "app_session_prog"
    t.boolean  "app_session_extended"
    t.boolean  "app_session_supplier"
    t.boolean  "boot_session_default"
    t.boolean  "boot_session_prog"
    t.boolean  "boot_session_extended"
    t.boolean  "boot_session_supplier"
    t.boolean  "sec_locked"
    t.boolean  "sec_lev1"
    t.boolean  "sec_lev_11"
    t.boolean  "sec_supplier"
    t.boolean  "addr_phys"
    t.boolean  "addr_func"
    t.boolean  "supress_bit"
    t.boolean  "precondition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "uds_service_id"
    t.integer  "configuration_switch_id"
    t.text     "custom_code"
    t.boolean  "generate",                :default => true
  end

  add_index "uds_sub_services", ["configuration_switch_id"], :name => "index_uds_sub_services_on_configuration_switch_id"
  add_index "uds_sub_services", ["uds_service_id"], :name => "index_uds_sub_services_on_uds_service_id"

  create_table "units", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
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

  create_table "values", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

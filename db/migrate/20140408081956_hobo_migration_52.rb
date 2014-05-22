class HoboMigration52 < ActiveRecord::Migration
  def self.up
    create_table :fault_requirements do |t|
      t.string   :name
      t.string   :abbrev
      t.string   :abbrev_c
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :project_id
    end
    add_index :fault_requirements, [:project_id]

    create_table :fault_recurrence_times do |t|
      t.string   :name
      t.integer  :ms
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :fault_detection_moments do |t|
      t.string   :name
      t.text     :description
      t.text     :code
      t.boolean  :feedback_required, :default => true
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :fail_safe_commands do |t|
      t.string   :name
      t.text     :description
      t.boolean  :feedback_required, :default => true
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :faults do |t|
      t.string   :name
      t.string   :abbrev
      t.string   :abbrev_c
      t.text     :description
      t.string   :status_byte
      t.string   :dtc
      t.string   :dtc_prefix, :default => "P"
      t.text     :custom_detection_moment
      t.text     :custom_precondition
      t.text     :detection_condition
      t.string   :qualification_time
      t.text     :system_failsafe_mode
      t.text     :recovery_condition
      t.string   :recovery_time
      t.text     :custom_rehabilitation
      t.boolean  :feedback_required, :default => true
      t.boolean  :generate_can, :default => true
      t.string   :can_abbrev
      t.boolean  :activate_value, :default => true
      t.boolean  :include_fault, :default => true
      t.text     :error_detection_task
      t.text     :error_detection_task_init
      t.text     :recovery_detection_task
      t.text     :recovery_detection_task_init
      t.text     :rehabilitation_detection_task
      t.text     :rehabilitation_detection_task_init
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :fault_requirement_id
      t.integer  :fault_precondition_id
      t.integer  :fault_detection_moment_id
      t.integer  :fault_recurrence_time_id
      t.integer  :fault_rehabilitation_id
    end
    add_index :faults, [:fault_requirement_id]
    add_index :faults, [:fault_precondition_id]
    add_index :faults, [:fault_detection_moment_id]
    add_index :faults, [:fault_recurrence_time_id]
    add_index :faults, [:fault_rehabilitation_id]

    create_table :fault_preconditions do |t|
      t.string   :name
      t.text     :description
      t.text     :code
      t.boolean  :feedback_required, :default => true
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :fault_rehabilitations do |t|
      t.string   :name
      t.text     :description
      t.text     :code
      t.boolean  :feedback_required, :default => true
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :fault_fail_safe_commands do |t|
      t.boolean  :feedback_required, :default => true
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :fail_safe_command_id
      t.integer  :fault_id
      t.integer  :fail_safe_command_time_id
    end
    add_index :fault_fail_safe_commands, [:fail_safe_command_id]
    add_index :fault_fail_safe_commands, [:fault_id]
    add_index :fault_fail_safe_commands, [:fail_safe_command_time_id]

    create_table :fail_safe_command_times do |t|
      t.string   :name
      t.integer  :ms
      t.boolean  :feedback_required, :default => true
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :fault_requirements
    drop_table :fault_recurrence_times
    drop_table :fault_detection_moments
    drop_table :fail_safe_commands
    drop_table :faults
    drop_table :fault_preconditions
    drop_table :fault_rehabilitations
    drop_table :fault_fail_safe_commands
    drop_table :fail_safe_command_times
  end
end

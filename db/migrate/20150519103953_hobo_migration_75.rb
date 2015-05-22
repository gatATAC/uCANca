class HoboMigration75 < ActiveRecord::Migration
  def self.up
    create_table :uds_sub_services do |t|
      t.string   :ident
      t.string   :name
      t.integer  :length
      t.boolean  :app_session_default
      t.boolean  :app_session_prog
      t.boolean  :app_session_extended
      t.boolean  :app_session_supplier
      t.boolean  :boot_session_default
      t.boolean  :boot_session_prog
      t.boolean  :boot_session_extended
      t.boolean  :boot_session_supplier
      t.boolean  :sec_locked
      t.boolean  :sec_lev1
      t.boolean  :sec_lev_11
      t.boolean  :sec_supplier
      t.boolean  :addr_phys
      t.boolean  :addr_func
      t.boolean  :supress_bit
      t.boolean  :precondition
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :uds_service_id
    end
    add_index :uds_sub_services, [:uds_service_id]

    create_table :uds_services do |t|
      t.string   :ident
      t.string   :name
      t.integer  :length
      t.boolean  :app_session_default
      t.boolean  :app_session_prog
      t.boolean  :app_session_extended
      t.boolean  :app_session_supplier
      t.boolean  :boot_session_default
      t.boolean  :boot_session_prog
      t.boolean  :boot_session_extended
      t.boolean  :boot_session_supplier
      t.boolean  :sec_locked
      t.boolean  :sec_lev1
      t.boolean  :sec_lev_11
      t.boolean  :sec_supplier
      t.boolean  :addr_phys
      t.boolean  :addr_func
      t.boolean  :supress_bit
      t.boolean  :precondition
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :uds_security_levels do |t|
      t.string   :ident
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :uds_service_managers do |t|
      t.string   :ident
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :uds_service_identifiers do |t|
      t.string   :ident
      t.string   :name
      t.integer  :length
      t.boolean  :app_session_default
      t.boolean  :app_session_prog
      t.boolean  :app_session_extended
      t.boolean  :app_session_supplier
      t.boolean  :boot_session_default
      t.boolean  :boot_session_prog
      t.boolean  :boot_session_extended
      t.boolean  :boot_session_supplier
      t.boolean  :sec_locked
      t.boolean  :sec_lev1
      t.boolean  :sec_lev_11
      t.boolean  :sec_supplier
      t.boolean  :addr_phys
      t.boolean  :addr_func
      t.boolean  :supress_bit
      t.boolean  :precondition
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :uds_sub_service_id
    end
    add_index :uds_service_identifiers, [:uds_sub_service_id]

    create_table :uds_adressings do |t|
      t.string   :ident
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :uds_service_fixed_params do |t|
      t.string   :ident
      t.string   :name
      t.integer  :length
      t.boolean  :app_session_default
      t.boolean  :app_session_prog
      t.boolean  :app_session_extended
      t.boolean  :app_session_supplier
      t.boolean  :boot_session_default
      t.boolean  :boot_session_prog
      t.boolean  :boot_session_extended
      t.boolean  :boot_session_supplier
      t.boolean  :sec_locked
      t.boolean  :sec_lev1
      t.boolean  :sec_lev_11
      t.boolean  :sec_supplier
      t.boolean  :addr_phys
      t.boolean  :addr_func
      t.boolean  :supress_bit
      t.boolean  :precondition
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :uds_sub_service_id
    end
    add_index :uds_service_fixed_params, [:uds_sub_service_id]

    create_table :uds_sessions do |t|
      t.string   :ident
      t.string   :name
      t.string   :sub_name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :uds_apps do |t|
      t.string   :ident
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :uds_sub_services
    drop_table :uds_services
    drop_table :uds_security_levels
    drop_table :uds_service_managers
    drop_table :uds_service_identifiers
    drop_table :uds_adressings
    drop_table :uds_service_fixed_params
    drop_table :uds_sessions
    drop_table :uds_apps
  end
end

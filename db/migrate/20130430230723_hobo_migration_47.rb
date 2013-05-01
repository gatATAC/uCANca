class HoboMigration47 < ActiveRecord::Migration
  def self.up
    create_table :st_mach_sys_maps do |t|
      t.boolean  :implementation
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :state_machine_id
      t.integer  :sub_system_id
    end
    add_index :st_mach_sys_maps, [:state_machine_id]
    add_index :st_mach_sys_maps, [:sub_system_id]
  end

  def self.down
    drop_table :st_mach_sys_maps
  end
end

class AddSubSystemType < ActiveRecord::Migration
  def self.up
    create_table :sub_system_types do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :sub_systems, :sub_system_type_id, :integer

    add_index :sub_systems, [:sub_system_type_id]
    
    SubSystemType.create :name => "Hardware", :abbrev => "hw"
    SubSystemType.create :name => "Software", :abbrev => "sw"    
    SubSystemType.create :name => "Mechanics", :abbrev => "mech"    
    SubSystemType.create :name => "Complex", :abbrev => "cplx"
    
  end

  def self.down
    remove_column :sub_systems, :sub_system_type_id

    drop_table :sub_system_types

    remove_index :sub_systems, :name => :index_sub_systems_on_sub_system_type_id rescue ActiveRecord::StatementInvalid
  end
end

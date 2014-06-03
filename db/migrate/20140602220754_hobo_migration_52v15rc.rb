class HoboMigration52v15Rc < ActiveRecord::Migration
  def self.up
    create_table :targets do |t|
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :sub_systems, :target_id, :integer

    add_column :projects, :target_id, :integer

    add_index :sub_systems, [:target_id]

    add_index :projects, [:target_id]
  end

  def self.down
    remove_column :sub_systems, :target_id

    remove_column :projects, :target_id

    drop_table :targets

    remove_index :sub_systems, :name => :index_sub_systems_on_target_id rescue ActiveRecord::StatementInvalid

    remove_index :projects, :name => :index_projects_on_target_id rescue ActiveRecord::StatementInvalid
  end
end

class HoboMigration12 < ActiveRecord::Migration
  def self.up
    add_column :functions, :function_type_id, :integer

    add_index :functions, [:function_type_id]
  end

  def self.down
    remove_column :functions, :function_type_id

    remove_index :functions, :name => :index_functions_on_function_type_id rescue ActiveRecord::StatementInvalid
  end
end

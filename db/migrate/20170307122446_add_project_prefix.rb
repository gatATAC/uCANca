class AddProjectPrefix < ActiveRecord::Migration
  def self.up
    add_column :projects, :prefix, :string
  end

  def self.down
    remove_column :projects, :prefix
  end
end

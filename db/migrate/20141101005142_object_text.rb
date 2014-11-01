class ObjectText < ActiveRecord::Migration
  def self.up
    change_column :requirements, :object_text, :text, :limit => nil
  end

  def self.down
    change_column :requirements, :object_text, :string
  end
end

class ReqAttributes < ActiveRecord::Migration
  def self.up
    add_column :requirements, :object_number, :string
    add_column :requirements, :last_modified_on, :date
    add_column :requirements, :master_req_accepted, :boolean
  end

  def self.down
    remove_column :requirements, :object_number
    remove_column :requirements, :last_modified_on
    remove_column :requirements, :master_req_accepted
  end
end

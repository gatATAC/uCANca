class AddReqCreatedThrough < ActiveRecord::Migration
  def self.up
    create_table :req_created_throughs do |t|
      t.string   :name
      t.string   :abbrev
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :requirements, :req_created_through_id, :integer

    add_index :requirements, [:req_created_through_id]
    
    ReqCreatedThrough.create :name => "Manual Input", :abbrev => "Manual Input"
    ReqCreatedThrough.create :name => "Copying", :abbrev => "Copying"
    
  end

  def self.down
    remove_column :requirements, :req_created_through_id

    drop_table :req_created_throughs

    remove_index :requirements, :name => :index_requirements_on_req_created_through_id rescue ActiveRecord::StatementInvalid
  end
end

class AddEdiProcess < ActiveRecord::Migration
  def self.up
    create_table :edi_processes do |t|
      t.integer  :ident
      t.string   :label
      t.integer  :pos_x
      t.integer  :pos_y
      t.integer  :size_x
      t.integer  :size_y
      t.integer  :color
      t.boolean  :master
      t.text     :description
      t.string   :block_id
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :edi_model_id
      t.integer  :parent_id
    end
    add_index :edi_processes, [:edi_model_id]
    add_index :edi_processes, [:parent_id]
  end

  def self.down
    drop_table :edi_processes
  end
end

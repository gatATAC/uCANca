class AddXdiAttachments < ActiveRecord::Migration
  def self.up
    remove_column :edi_processes, :color

    add_column :edi_models, :xdi_file_name, :string
    add_column :edi_models, :xdi_content_type, :string
    add_column :edi_models, :xdi_file_size, :integer
    add_column :edi_models, :xdi_updated_at, :datetime
  end

  def self.down
    add_column :edi_processes, :color, :integer

    remove_column :edi_models, :xdi_file_name
    remove_column :edi_models, :xdi_content_type
    remove_column :edi_models, :xdi_file_size
    remove_column :edi_models, :xdi_updated_at
  end
end

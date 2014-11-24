class EdiImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :req_doc_id, :req_doc

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    imported_req
    true
  end

  def imported_req
    @imported_req ||= load_imported_req
  end

  def load_imported_req
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".xdi" then EdiModel.import(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
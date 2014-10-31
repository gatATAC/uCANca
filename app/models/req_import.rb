class ReqImport
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
    spreadsheet = open_spreadsheet
    # Requirements
    ucanca_sheet=spreadsheet.sheet('Import')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
         print "fila "+i.to_s+"\n"
      else
        nil
      end
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    when ".ods" then Roo::OpenOffice.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
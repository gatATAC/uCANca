class ProjectFlowsImport
  
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :project_id, :project

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if imported_project_flows.map(&:valid?).all?
      imported_project_flows.each(&:save!)
      true
    else
      imported_project_flows.each_with_index do |flow, index|
        flow.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end
  end

  def imported_project_flows
    @imported_project_flows ||= load_imported_project_flows
  end

  def load_imported_project_flows
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      flow = Flow.find_by_name(row["name"]) || Flow.find_by_name(row["old_name"]) || Flow.new
      flow.attributes = row.to_hash.slice(*Flow.import_attributes)
      flow.project_id=self.project_id
      flow
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

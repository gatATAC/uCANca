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
    imported_project_flows
    true
  end
=begin
    imported_project_flows.each_with_index {|flow,index|
      if (flow.valid?)
        flow.save!
      else
        flow.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
    }
=end

  def imported_project_flows
    @imported_project_flows ||= load_imported_project_flows
  end

  def load_imported_project_flows
    spreadsheet = open_spreadsheet
    ucanca_sheet=spreadsheet.sheet('uCANca Import')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      print "\ntrato "+i.to_s
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
        flow = project.flows.find_by_name(row["name"]) || project.flows.find_by_name(row["old_name"]) || Flow.new
        flow.attributes = row.to_hash.slice(*Flow.import_attributes)
        flow.project_id=self.project_id
        dir=FlowDirection.find_by_name(row["primary_flow_direction"])
        flow.primary_flow_direction=dir
        print "\Importamos: "+flow.attributes.to_s
        if (flow.valid?)
          flow.save!
          subs=project.sub_systems.find_by_abbrev(row["sub_system"]) 
          if subs==nil 
            subs=project.sub_systems.new
            subs.name=(row["sub_system"])
            subs.abbrev=(row["sub_system"])
            subs.layer=Layer.find_by_level(1)
            if subs.valid?
              subs.save!
            end
          end
          # Let's see if we have to create a connector
          con=subs.connectors.find_by_name(row["connector"]) 
          if con == nil
            con=subs.connectors.new
            con.name=row["connector"];
            if con.valid?
              con.save!          
            end
          end
          # Let's see if we have to create a sub_system_flow
          ssf=con.sub_system_flows.find_by_flow_id(flow.id)
          if ssf==nil 
            ssf=con.sub_system_flows.new
            ssf.flow=flow
          end
          ssf.flow_direction=dir
          ssf.context_name=row["context_name"]
          if ssf.valid?
            ssf.save!
          end
          flow
        else
          flow.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end
        # Let's see if we have to create a subsystem
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

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
=begin
    ucanca_sheet=spreadsheet.sheet('Import')
    header = ucanca_sheet.row(1)
    contador=0
    (2..ucanca_sheet.last_row).map do |i|
      if (contador==10) then
        break
      end
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row['object_identifier']!=nil && row['object_identifier']!="")
        print "fila "+i.to_s+": "+row['object_identifier']+"\n"
        # First let's load the req_type
        rqt=ReqType.find_by_abbrev(row['req_type'])
        if (rqt!=nil) then
          rqt=ReqType.create :name => row['req_type'], :abbrev => row['req_type']
          rqt.save!
        end
        # Then let's load the sw_req_type
        swrqt=ReqType.find_by_abbrev(row['sw_req_type'])
        if (swrqt!=nil) then
          swrqt=SwReqType.create :name => row['sw_req_type'], :abbrev => row['sw_req_type']
          swrqt.save!
        end
        if (row['req_target_micro']!=nil && row['req_target_micro']!="")
          # Then let's load the target_micro
          rqtm=ReqTargetMicro.find_by_abbrev(row['req_target_micro'])
          if (rqtm!=nil) then
            rqtm=ReqTargetMicro.create :name => row['req_target_micro'], :abbrev => row['req_target_micro']
            rqtm.save!
          end      
        end        
        # Then let's load the rq_creater_through
        rqct=ReqCreatedThrough.find_by_abbrev(row['req_created_through'])
        if (rqct!=nil) then
          rqct=ReqCreatedThrough.create :name => row['req_created_through'], :abbrev => row['req_created_through']
          rqct.save!
        end
        # Then let's load the rq_creater_through
        rqcrt=ReqCriticality.find_by_abbrev(row['req_criticality'])
        if (rqcrt!=nil) then
          rqcrt=ReqCriticality.create :name => row['req_criticality'], :abbrev => row['req_criticality']
          rqcrt.save!
        end
        # Then let's load the rq_creater_through
        rqcrt=ReqCriticality.find_by_abbrev(row['req_criticality'])
        if (rqcrt!=nil) then
          rqcrt=ReqCriticality.create :name => row['req_criticality'], :abbrev => row['req_criticality']
          rqcrt.save!
        end
        
        
        rd=ReqDoc.find_by_id(self.req_doc_id)
        requirement = rd.requirements.find_by_object_identifier(row["object_identifier"]) || Requirement.new
        requirement.attributes = row.to_hash.slice(*Requirement.import_attributes)
        requirement.req_doc_id=self.req_doc_id
        requirement.req_type=rqt
        requirement.sw_req_type=swrqt
        requirement.req_created_through=rqct
        if rqtm!=nil then
          requirement.req_target_micro=rqtm
        end
        print "\Importamos: "+requirement.attributes.to_s
        if (requirement.valid?)
          requirement.save!
          requirement
        else
          requirement.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end       
        contador=0
      else
        print "Nos saltamos la fila "+i.to_s+" contador="+contador.to_s+"\n"
        # Al llegar a 10 filas sin nada, cortamos
        contador=contador+1
        nil
      end
    end
=end
    #Links
    ucanca_sheet=spreadsheet.sheet('HyperLinks')
    header = ucanca_sheet.row(1)
    contador=0
    (2..ucanca_sheet.last_row).map do |i|
      if (contador==10) then
        break
      end
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row['req_ident']!=nil && row['req_ident']!="")
        print "fila "+i.to_s+": "+row['req_ident']+"\n"
        contador=0
        rq=Requirement.find_by_object_identifier(row['req_ident'])
        rq2=Requirement.find_by_object_identifier(row['req_source'])
        rql=rq.req_links.find_by_req_source_id(rq2.id)
        if (rql==nil) then
          rql=ReqLink.new
          rql.requirement=rq
          rql.req_source=rq2
        end
        rql.ext_url=row['ext_url']
      else
        print "Nos saltamos la fila "+i.to_s+" contador="+contador.to_s+"\n"
        # Al llegar a 10 filas sin nada, cortamos
        contador=contador+1
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
class DiagnosticsImport
  
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
    imported_diagnostics
    true
  end

  def imported_diagnostics
    @imported_diagnostics ||= load_imported_diagnostics
  end

  def load_imported_diagnostics
    spreadsheet = open_spreadsheet

    # Recurrence Times
    ucanca_sheet=spreadsheet.sheet('Recurrence Times')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
        recurrence_time = project.fault_recurrence_times.find_by_name(row["name"]) || project.fault_recurrence_times.find_by_name(row["old_name"]) || FaultRecurrenceTime.new
        recurrence_time.attributes = row.to_hash.slice(*FaultRecurrenceTime.import_attributes)
        recurrence_time.project_id=self.project_id
        print "\Importamos: "+recurrence_time.attributes.to_s
        if (recurrence_time.valid?)
          recurrence_time.save!
          recurrence_time
        else
          recurrence_time.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end
        # Let's see if we have to create a subsystem
      else
        nil
      end
    end
    
    # FailSafe Commands
    ucanca_sheet=spreadsheet.sheet('Failsafe Commands')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
        failsafe_command = project.fail_safe_commands.find_by_name(row["name"]) || project.fail_safe_commands.find_by_name(row["old_name"]) || FailSafeCommand.new
        failsafe_command.attributes = row.to_hash.slice(*FailSafeCommand.import_attributes)
        failsafe_command.project_id=self.project_id
        print "\Importamos: "+failsafe_command.attributes.to_s
        if (failsafe_command.valid?)
          failsafe_command.save!
          failsafe_command
        else
          failsafe_command.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end
        # Let's see if we have to create a subsystem
      else
        nil
      end
    end

    # FailSafe Times
    ucanca_sheet=spreadsheet.sheet('FailSafe Times')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
        failsafe_time = project.fail_safe_command_times.find_by_name(row["name"]) || project.fail_safe_command_times.find_by_name(row["old_name"]) || FailSafeCommandTime.new
        failsafe_time.attributes = row.to_hash.slice(*FailSafeCommandTime.import_attributes)
        failsafe_time.project_id=self.project_id
        print "\Importamos: "+failsafe_time.attributes.to_s
        if (failsafe_time.valid?)
          failsafe_time.save!
          failsafe_time
        else
          failsafe_time.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end
        # Let's see if we have to create a subsystem
      else
        nil
      end
    end
    
    # Detection Moments
    ucanca_sheet=spreadsheet.sheet('Detection Moments')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
        detection_moment = project.fault_detection_moments.find_by_name(row["name"]) || project.fault_detection_moments.find_by_name(row["old_name"]) || FaultDetectionMoment.new
        detection_moment.attributes = row.to_hash.slice(*FaultDetectionMoment.import_attributes)
        detection_moment.project_id=self.project_id
        print "\Importamos: "+detection_moment.attributes.to_s
        if (detection_moment.valid?)
          detection_moment.save!
          detection_moment
        else
          detection_moment.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end
        # Let's see if we have to create a subsystem
      else
        nil
      end
    end
    
    # Preconditions
    ucanca_sheet=spreadsheet.sheet('Preconditions')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
        precondition = project.fault_preconditions.find_by_name(row["name"]) || project.fault_preconditions.find_by_name(row["old_name"]) || FaultPrecondition.new
        precondition.attributes = row.to_hash.slice(*FaultPrecondition.import_attributes)
        precondition.project_id=self.project_id
        print "\Importamos: "+precondition.attributes.to_s
        if (precondition.valid?)
          precondition.save!
          precondition
        else
          precondition.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end
        # Let's see if we have to create a subsystem
      else
        nil
      end
    end
    
    # Rehabilitations
    ucanca_sheet=spreadsheet.sheet('Rehabilitations')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
        rehabilitation = project.fault_rehabilitations.find_by_name(row["name"]) || project.fault_rehabilitations.find_by_name(row["old_name"]) || FaultRehabilitation.new
        rehabilitation.attributes = row.to_hash.slice(*FaultRehabilitation.import_attributes)
        rehabilitation.project_id=self.project_id
        print "\Importamos: "+rehabilitation.attributes.to_s
        if (rehabilitation.valid?)
          rehabilitation.save!
          rehabilitation
        else
          rehabilitation.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end
        # Let's see if we have to create a subsystem
      else
        nil
      end
    end
    
    # First, we import the fault requirements
    ucanca_sheet=spreadsheet.sheet('Requirements Import')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      print "\ntrato "+i.to_s
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      if (row["name"]!=nil && row["name"]!="")
        fault_requirement = project.fault_requirements.find_by_name(row["name"]) || project.fault_requirements.find_by_name(row["old_name"]) || FaultRequirement.new
        fault_requirement.attributes = row.to_hash.slice(*FaultRequirement.import_attributes)
        fault_requirement.project_id=self.project_id
        
        fflow=project.flows.find_by_name(row["flow"])
        if (fflow)
          fault_requirement.flow=fflow
        end
        
        print "\Importamos: "+fault_requirement.attributes.to_s
        if (fault_requirement.valid?)
          fault_requirement.save!
          fault_requirement
        else
          fault_requirement.errors.full_messages.each do |message|
            errors.add :base, "Row #{i+2}: #{message}"
          end
          nil
        end
        # Let's see if we have to create a subsystem
      else
        nil
      end
    end
    
    # Import now the faults
    ucanca_sheet=spreadsheet.sheet('Faults Import')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      print "\ntrato "+i.to_s
      if (row["name"]!=nil && row["name"]!="")
        print " name: "+row["name"]
        fr = project.fault_requirements.find_by_name(row["requirement"]) 
        if (fr)
          fault = fr.faults.find_by_name(row["name"]) || fr.faults.find_by_name(row["old_name"]) || Fault.new
          print "\nRow: "+row.to_s
          print "\nFault import attributes "+Fault.import_attributes.to_s
          fault.attributes = row.to_hash.slice(*Fault.import_attributes)
          print "\nFault attributes "+fault.attributes.to_s
          fault.fault_requirement_id=fr.id
          if (fault.custom_detection_moment == nil)
            # Buscamos el detection moment
            fdm=project.fault_detection_moments.find_by_name(row["fault_detection_moment"])
            if (fdm!=nil)
              fault.fault_detection_moment=fdm
            end
          end
          if (fault.custom_precondition == nil)
            # Buscamos el detection moment
            fp=project.fault_preconditions.find_by_name(row["fault_precondition"])
            if (fp!=nil)
              fault.fault_precondition=fp
            end
          end
          if (fault.custom_rehabilitation == nil)
            # Buscamos el rehabilitation
            frh=project.fault_rehabilitations.find_by_name(row["fault_rehabilitation"])
            if (frh!=nil)
              fault.fault_rehabilitation=frh
            end
          end
          # Buscamos el recurrence time
          frt=project.fault_recurrence_times.find_by_name(row["fault_recurrence_time"])
          if (frt!=nil)
            fault.fault_recurrence_time=frt
          end

          fflow=project.flows.find_by_name(row["flow"])
          if (fflow)
            fault.flow=fflow
          end
       
          print "\nImportamos: "+fault.attributes.to_s
          if (fault.valid?)
            fault.save!
            print ("GRABADO!!!!!!\n")
            fault
          else
            fault.errors.full_messages.each do |message|
              errors.add :base, "Row #{i+2}: #{message}"
              print ("ERROR!!!!!!Row #{i+2}: #{message}\n")
            end
            nil
          end
        else
          nil
        end
        # Let's see if we have to create a subsystem
      else
        nil
      end

    end

    # Import now the fault failsafe commands
    ucanca_sheet=spreadsheet.sheet('FaultFailSafeCommands')
    header = ucanca_sheet.row(1)
    (2..ucanca_sheet.last_row).map do |i|
      row = Hash[[header, ucanca_sheet.row(i)].transpose]
      print "\ntrato "+i.to_s+" fault: "+row["fault"]
      if (row["fault"]!=nil && row["fault"]!="")
        print "uno"
        # Busco si existe el fault
        fl = project.faults.find_by_description(row["fault"]) 
        if (fl)
          # Busco si existe el command
          fsc = project.fail_safe_commands.find_by_name(row["fault_safe_command"])
          if (fsc)
            # Existen los dos, voy a ver si existe el fault_fail_safe_command, y si no lo creo
            ffsc = fl.fault_fail_safe_commands.find_by_fail_safe_command_id(fsc.id)
            if (!ffsc)
              ffsc=FaultFailSafeCommand.new
              ffsc.fault=fl
              ffsc.fail_safe_command=fsc
            end
            ffsc.attributes = row.to_hash.slice(*FaultFailSafeCommand.import_attributes)
            # Buscamos el command time
            ffsct=project.fail_safe_command_times.find_by_name(row["fail_safe_command_time"])
            if (ffsct!=nil)
              ffsc.fail_safe_command_time=ffsct
            end
          end

          print "\nImportamos: "+ffsc.attributes.to_s
          if (ffsc.valid?)
            ffsc.save!
            print ("GRABADO!!!!!!\n")
            ffsc
          else
            ffsc.errors.full_messages.each do |message|
              errors.add :base, "Row #{i+2}: #{message}"
              print ("ERROR!!!!!!Row #{i+2}: #{message}\n")
            end
            nil
          end
        else
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
    when ".csv" then Roo::Csv.new(file.path,{:file_warning => :ignore})
    when ".xls" then Roo::Excel.new(file.path,{:file_warning => :ignore})
    when ".xlsx" then Roo::Excelx.new(file.path,{:file_warning => :ignore})
    when ".ods" then Roo::OpenOffice.new(file.path,{:file_warning => :ignore})
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end

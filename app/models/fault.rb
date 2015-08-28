class Fault < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name                 :string, :required
    abbrev               :string, :required
    abbrev_c :string, :required
    description          :text
    status_byte          :string, :required
    dtc                  :string, :required
    dtc_prefix           :string, :required, :default => "P"
    custom_detection_moment     :text
    custom_precondition         :text
    detection_condition  :text, :required
    qualification_time   :string    #empty for autogenerating, - for no time.
    recovery_condition   :text, :required
    recovery_time        :string  #empty for autogenerating, - for no time.
    custom_rehabilitation       :text
    feedback_required :boolean, :default => true
    generate_can :boolean, :default => true
    can_abbrev  :string
    activate_value :boolean, :default => true
    include_fault :boolean, :default => true
    error_detection_task :text
    error_detection_task_init :text
    recovery_detection_task :text
    recovery_detection_task_init :text
    rehabilitation_detection_task :text
    rehabilitation_detection_task_init :text
    failure_flag :string, :required
    test_completed_flag :string, :required
    diag_activate_flag :string, :required
    
    timestamps
  end
  attr_accessible :name, :flow, :flow_id, :abbrev, :abbrev_c, :description, :status_byte, :dtc, :dtc_prefix, :custom_detection_moment, :custom_precondition, :detection_condition, :qualification_time, :recovery_condition, :recovery_time, :custom_rehabilitation, :feedback_required, :generate_can, :can_abbrev, :activate_value, :include_fault, :error_detection_task, :error_detection_task_init, :recovery_detection_task, :recovery_detection_task_init, :rehabilitation_detection_task, :rehabilitation_detection_task_init, :fault_detection_moment,:fault_detection_moment_id, :fault_precondition, :fault_precondition_id, :fault_recurrence_time, :fault_recurrence_time_id, :fault_rehabilitation, :fault_rehabilitation_id, :failure_flag, :test_completed_flag, :diag_activate_flag
  
  belongs_to :fault_requirement, :creator => true
  belongs_to :fault_precondition
  has_many :fault_fail_safe_commands, :dependent => :destroy, :accessible => true, :inverse_of => :fault
  has_many :fail_safe_commands, :through => :fault_fail_safe_commands, :accessible => true
  belongs_to :fault_detection_moment
  belongs_to :fault_recurrence_time
  belongs_to :fault_rehabilitation
  
  belongs_to :flow
  
  children :fault_fail_safe_commands

  def project
    fault_requirement.project
  end
  
  ################ Code generation


  def to_structure
    if self.include_fault
      ret="\n//"
      ret+=self.name
      ret+="\n"
      ret+="BOOL _"+self.failure_flag+";\n"
      ret+="BOOL _"+self.test_completed_flag+";"
      return ret
    else
      ""
    end
  end

  def to_structure_define
    if self.include_fault
      ret="#define "+self.failure_flag+" ad_output._"+self.failure_flag+"\n"
      ret+="#define "+self.test_completed_flag+" ad_output._"+self.test_completed_flag+"\n"
      return ret
    else
      ""
    end
  end

  def activate_value_string
    if self.activate_value then
      "FALSE"
    else
      "TRUE"
    end
  end

  def to_autodiag_main
    if self.include_fault
      @code="extern t_yy_autodiag_data ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+";\n"
      @code+="void AD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"_init();\n"
      @code+="void AD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"();\n"
    else
      ""
    end
  end

  def to_autodiag_main_c
    if self.include_fault
      @code="/////////////////// "+self.fault_requirement.abbrev+"_"+self.abbrev+"\n\n"
      @code+="t_yy_autodiag_data ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+";\n\n"
      @code+="void AD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"_init(){\n"
      data_str="ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c;
      if (self.fault_recurrence_time) then
        @code+="\t"+data_str+".T_DIAGNOSTICS="+self.fault_recurrence_time.name+";\n"
      else
        @code+="\t"+data_str+".T_DIAGNOSTICS=0;\n"
      end
      if (self.qualification_time!="-") then
          @code+="\t"+data_str+".T_QUALIFICATION="+self.qualification_time+";\n"
      else
        @code+="\t"+data_str+".T_QUALIFICATION=0;\n"
      end
      if (self.recovery_time!="-") then
        @code+="\t"+data_str+".T_RECOVERY="+self.recovery_time+";\n"
      else
        @code+="\t"+data_str+".T_RECOVERY=0;\n"
      end
      @code+="\t"+data_str+".estat_yyautodiag=ESTAT_0_YYAUTODIAG;\n"
      @code+="\t"+data_str+".estat_checking=ESTAT_0_YYAUTODIAG;\n"
      @code+="\t"+data_str+".temps_checking=0;\n"
      @code+="\t"+data_str+".time_accum=0;\n"
      @code+="\t"+data_str+".detection_moment_conditions=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_detection_moment_conditions;\n"
      @code+="\t"+data_str+".error_detection_task=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_detection_task;\n"
      @code+="\t"+data_str+".recovery_detection_task=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_detection_task;\n"
      @code+="\t"+data_str+".rehabilitation_detection_task=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_detection_task;\n"
      @code+="\t"+data_str+".error_detection_task_init=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_detection_task_init;\n"
      @code+="\t"+data_str+".recovery_detection_task_init=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_detection_task_init;\n"
      @code+="\t"+data_str+".rehabilitation_detection_task_init=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_detection_task_init;\n"
      @code+="\t"+data_str+".preconditions_present=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_preconditions_present;\n"
      @code+="\t"+data_str+".error_conditions=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_conditions;\n"
      @code+="\t"+data_str+".set_failure_mode=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_failure_mode;\n"
      @code+="\t"+data_str+".clear_failure_mode=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_failure_mode;\n"
      @code+="\t"+data_str+".set_fault=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_fault;\n"
      @code+="\t"+data_str+".clear_fault=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_fault;\n"
      @code+="\t"+data_str+".recovery_conditions=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_conditions;\n"
      @code+="\t"+data_str+".rehabilitation_conditions=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_conditions;\n"
      @code+="\t"+data_str+".diag_busy=FALSE;\n"
      @code+="\t"+data_str+".fault_present=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_fault_present;\n"
      @code+="\t"+data_str+".set_tci=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_tci;\n"
      @code+="\t"+data_str+".clear_tci=ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_tci;\n"
      @code+="\t"+data_str+".TEST_TIMES_CAL=ctDiagRunMinTime_cal;\n"
      @code+="\t// Flags initialization \n"
      @code+="\t"+self.failure_flag+"=FALSE;\n"
      @code+="\t"+self.test_completed_flag+"=FALSE;\n"
      @code+="\n\tYYAutoDiagInicialitza(&ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+");\n"
      @code+="}\n\n"

      @code+="void AD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"(){\n"
      @code+="\tif ("+self.diag_activate_flag+" == TRUE) {\n"
      @code+="\t\tYYAutoDiag(&ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+");\n"
      @code+="\t}\n"
      @code+="}\n\n"
    else
      ""
    end
  end

  def to_autodiag_main_functions_c
    if self.include_fault
      @code="/////////////////// "+self.fault_requirement.abbrev+"_"+self.abbrev+"\n\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_detection_moment_conditions(){\n"
      if self.fault_detection_moment then
        @code+="\t"+self.fault_detection_moment.code+"\n"
      else
        @code+="\t"+self.custom_detection_moment+"\n"
      end
      @code+="}\n\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_preconditions_present(){\n"
      if self.fault_precondition then
        @code+="\t"+self.fault_precondition.code+"\n"
      else
        @code+="\treturn ("+self.custom_precondition+");\n"
      end
      @code+="}\n\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_conditions(){\n"
      @code+="\treturn ("+self.detection_condition.to_s+");\n"
      @code+="}\n\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_conditions(){\n"
      @code+="\treturn ("+self.recovery_condition+");\n"
      @code+="}\n\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_conditions(){\n"
      if self.fault_rehabilitation then
        if (self.fault_rehabilitation.name=="Synchronize with recovery condition") then
          @code+=self.fault_rehabilitation.code+"\n\n\t/** Just call the recovery condition for this fault ***/\n\treturn(ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_conditions());\n"
        elsif (self.fault_rehabilitation.name=="Custom Rehabilitation") then
            @code+="\t"+self.fault_rehabilitation.code+"\n"
            @code+="\t"+self.custom_rehabilitation+"\n"
        else
          @code+="\t"+self.fault_rehabilitation.code+"\n"
        end
      else
        @code+="\t"+self.custom_rehabilitation+"\n"
      end
      @code+="}\n\n"

      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_detection_task(){\n"
      if (self.error_detection_task) then
        @code+=error_detection_task
      end
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_detection_task(){\n"
      if (self.recovery_detection_task) then
        @code+=recovery_detection_task
      end
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_detection_task(){\n"
      if (self.rehabilitation_detection_task) then
        @code+=rehabilitation_detection_task
      end
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_detection_task_init(){\n"
      if (self.error_detection_task_init) then
        @code+=error_detection_task_init
      end
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_detection_task_init(){\n"
      if (self.recovery_detection_task_init) then
        @code+=recovery_detection_task_init
      end
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_detection_task_init(){\n"
      if (self.rehabilitation_detection_task_init) then
        @code+=rehabilitation_detection_task_init
      end
      @code+="}\n\n"

      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_failure_mode(){\n"
      self.fault_fail_safe_commands.each { |e|
        if (e.fail_safe_command_time==nil) then
          #untimed client
          @code+="\tset_failsafe_command(&"+e.fail_safe_command.name+",FALSE,0);\n"
        else
          #timed client
          @code+="\tset_failsafe_command(&"+e.fail_safe_command.name+",TRUE,TIMER_MS_TO_TICKS("+e.fail_safe_command_time.name+"));\n"
        end
      }
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_failure_mode(){\n"
      self.fault_fail_safe_commands.each { |e|
        if (e.fail_safe_command_time==nil) then
          #untimed client
          @code+="\tclear_failsafe_command(&"+e.fail_safe_command.name+",FALSE);\n"
        else
          #timed client
          @code+="\tclear_failsafe_command(&"+e.fail_safe_command.name+",TRUE);\n"
        end
      }
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_fault(){\n"
      @code+="\t"+self.failure_flag+"=TRUE;\n"
      @code+="\tad_set_dtc(DTC_"+self.dtc_prefix+self.dtc+");\n"
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_fault(){\n"
      @code+="\t"+self.failure_flag+"=FALSE;\n"
      @code+="\tad_recover_dtc(DTC_"+self.dtc_prefix+self.dtc+");\n"
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_tci(){\n"
      @code+="\t"+self.test_completed_flag+"=TRUE;\n"
      @code+="}\n\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_tci(){\n"
      @code+="\t"+self.test_completed_flag+"=FALSE;\n"
      @code+="}\n\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_fault_present(){\n"
      @code+="\treturn ("+self.failure_flag+"==TRUE);\n"
      @code+="}\n\n"

    else
      ""
    end
  end

  def to_autodiag_main_functions
    if self.include_fault
      @code="/////////////////// "+self.fault_requirement.abbrev+"_"+self.abbrev+"\n\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_detection_moment_conditions();\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_preconditions_present();\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_conditions();\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_conditions();\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_conditions();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_detection_task();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_detection_task();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_detection_task();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_error_detection_task_init();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_recovery_detection_task_init();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_rehabilitation_detection_task_init();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_failure_mode();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_failure_mode();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_fault();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_fault();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_set_tci();\n"
      @code+="void ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_clear_tci();\n"
      @code+="BOOL ad_"+self.fault_requirement.abbrev_c+"_"+self.abbrev_c+"_fault_present();\n\n"
    else
      ""
    end
  end

  def to_diagmux
    if self.include_fault
      @code="void AD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"DiagMux(uint8_t level);\n"
    else
      ""
    end
  end

  def to_diagmux_c
    if self.include_fault
      @code="void AD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"DiagMux(uint8_t level){\n"
      @code+="\tAD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"();\n"
      @code+="}\n";
    else
      ""
    end
  end

  def to_diagmux_call_init
    if self.include_fault
      @code="\tAD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"_init();\n"
    else
      ""
    end
  end
  def to_diagmux_call_normal
    if self.include_fault
      @code="\tAD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"();\n"
    else
      ""
    end
  end
  def to_diagmux_call_mux
    if self.include_fault
      @code="\tAD_"+self.fault_requirement.abbrev+"_"+self.abbrev+"DiagMux(level);\n"
    else
      ""
    end
  end

  def get_can_abbrev
    if self.include_fault
      if self.can_abbrev && self.can_abbrev.length>=1 then
        return self.can_abbrev
      else
        return self.abbrev
      end
    else
      ""
    end
  end
  
  def to_sendmessage
    if self.include_fault
      if self.generate_can then
        @code="\t"
      else
        @code="\t//"
      end
      @code+="SendMessage(SIG_"+self.failure_flag.upcase+",&"+self.failure_flag+");\n"
      if self.generate_can then
        @code+="\t"
      else
        @code+="\t//"
      end
      @code+="SendMessage(SIG_"+self.test_completed_flag.upcase+",&"+self.test_completed_flag+");\n"
    else
      ""
    end
  end

  def to_dtc_a2l(index)
    @code="/begin MEASUREMENT dtc._"+index.to_s+"_.ident \"\"\n"
    @code+="UWORD NO_COMPU_METHOD 0 0 0 65535\n"
    @code+="BYTE_ORDER MSB_FIRST\n"
    @code+="ECU_ADDRESS 0x00000000\n"
    @code+="ECU_ADDRESS_EXTENSION 0x0\n"
    @code+="FORMAT \"%.15\"\n"
    @code+="/begin IF_DATA CANAPE_EXT\n"
    @code+="100\n"
    @code+="LINK_MAP \"dtc._0_.ident\" 0x00000000 0x0 0 "+(4*index).to_s+" 1 0x8F 0x0\n"
    @code+="DISPLAY 0 0 65535\n"
    @code+="/end IF_DATA\n"
    @code+="SYMBOL_LINK \"dtc._0_.ident\" "+(4*index).to_s+"\n"
    @code+="/end MEASUREMENT\n\n"

    @code+="/begin CHARACTERISTIC dtc._"+index.to_s+"_.low_byte \"\"\n"
    @code+="VALUE 0x00000000 __UBYTE_S 0 NO_COMPU_METHOD 0 255\n"
    @code+="ECU_ADDRESS_EXTENSION 0x0\n"
    @code+="EXTENDED_LIMITS 0 255\n"
    @code+="BYTE_ORDER MSB_FIRST\n"
    @code+="FORMAT \"%.15\"\n"
    @code+="/begin IF_DATA CANAPE_EXT\n"
    @code+="100\n"
    @code+="LINK_MAP \"dtc._0_.low_byte\" 0x00000000 0x0 0 "+(4*index).to_s+" 1 0x87 0x0\n"
    @code+="DISPLAY 0 0 255\n"
    @code+="/end IF_DATA\n"
    @code+="SYMBOL_LINK \"dtc._0_.low_byte\" "+(4*index).to_s+"\n"
    @code+="/end CHARACTERISTIC\n"
  end

  def to_dtc_code_valid
		@code="dtc[DTC_"+self.dtc_prefix+self.dtc+"].ident == 0x"+self.dtc
  end

  def to_dtc_code_init
		@code="dtc[DTC_"+self.dtc_prefix+self.dtc+"].ident = 0x"+self.dtc+";"
  end
  
  def self.import_attributes
    ret=self.accessible_attributes.clone
    ret.delete("fault_requirement_id")
    ret.delete("fault_requirement")
    #ret.delete("flow_type")
    ret.delete("")
    return ret
  end
  
  
  
  
  # --- Permissions --- #

  def create_permitted?
    fault_requirement.updatable_by?(acting_user)
  end

  def update_permitted?
    fault_requirement.updatable_by?(acting_user)
  end

  def destroy_permitted?
    fault_requirement.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    fault_requirement.viewable_by? (acting_user)
  end

end

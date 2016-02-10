class UdsServiceFixedParam < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident                 :string
    name                  :string
    length                :integer
    app_session_default   :boolean
    app_session_prog      :boolean
    app_session_extended  :boolean
    app_session_supplier  :boolean
    boot_session_default  :boolean
    boot_session_prog     :boolean
    boot_session_extended :boolean
    boot_session_supplier :boolean
    sec_locked            :boolean
    sec_lev1              :boolean
    sec_lev_11            :boolean
    sec_supplier          :boolean
    addr_phys             :boolean
    addr_func             :boolean
    supress_bit           :boolean
    precondition          :boolean
    custom_code           :text
    generate              :boolean  # TODO: quit this workaround to avoid problems with SQLite development DB, redo , :default => true
    timestamps
  end
  attr_accessible :ident, :name, :length, :app_session_default, :app_session_prog, :app_session_extended, :app_session_supplier, :boot_session_default, :boot_session_prog, :boot_session_extended, :boot_session_supplier, :sec_locked, :sec_lev1, :sec_lev_11, :sec_supplier, :addr_phys, :addr_func, :supress_bit, :precondition, :uds_service_sub, :uds_sub_service_id, :configuration_switch, :configuration_switch_id

  belongs_to :uds_service, :creator => :true, :inverse_of => :uds_service_fixed_params
  belongs_to :uds_sub_service, :inverse_of => :uds_service_fixed_params
  belongs_to :configuration_switch, :inverse_of => :uds_service_fixed_params

  def to_serv_fixparams_c(index,is_bootloader=false)
    
    if (!is_bootloader) then
      prefix="UDS_SERV_FIXPARAMS_"
    else
      prefix="UDS_BL_SERV_FIXPARAMS_"
    end
    
    retinit="\n\t/*  "+self.name+"  */\n"
    ret="\n/*  "+self.name+"  */\n"
    retswitch="\n\t/*  "+self.name+"  */\n"
    if (self.configuration_switch!=nil) then
      retinit+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
      ret+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
      retswitch+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
    end

    if ((!is_bootloader and self.app_session_default) or (is_bootloader and self.boot_session_default)) then
      retinit+="\tuds_serv_fixparams_permission_session_default["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_prog) or (is_bootloader and self.boot_session_prog)) then
      retinit+="\tuds_serv_fixparams_permission_session_prog["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_extended) or (is_bootloader and self.boot_session_extended)) then
      retinit+="\tuds_serv_fixparams_permission_session_extended["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_supplier) or (is_bootloader and self.boot_session_supplier)) then
      retinit+="\tuds_serv_fixparams_permission_session_supplier["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
        
    if (self.sec_locked) then
      retinit+="\tuds_serv_fixparams_permission_security_locked["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev1) then
      retinit+="\tuds_serv_fixparams_permission_security_level1["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev_11) then
      retinit+="\tuds_serv_fixparams_permission_security_level11["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
    if (self.sec_supplier) then
      retinit+="\tuds_serv_fixparams_permission_security_supplier["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
    if (self.addr_phys) then
      retinit+="\tuds_serv_fixparams_permission_addressing_physical["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end
    if (self.addr_func) then
      retinit+="\tuds_serv_fixparams_permission_addressing_functional["+prefix+self.complete_c_define_name+"_NUMBYTE]|="+prefix+self.complete_c_define_name+"_BITMASK;\n"
    end

    ret+="BOOL UDSServWithFixParams_"+self.complete_c_name+"(uint8_t *data_buffer, uint8_t index, uint16_t *data_size)\n{\n"
    ret+="\t/* TODO: fill this */ \n\treturn TRUE;\n"
    ret+="}\n"
    retswitch +="        case "+prefix+self.complete_c_define_name+"_ID: 
            if (UDSServWithFixParams_check_permissions("+prefix+self.complete_c_define_name+"_NUMBYTE,"+prefix+self.complete_c_define_name+"_BITMASK ,&response_mode)==TRUE){ 
                if (UDSServWithFixParams_"+self.complete_c_name+"(resp->buffer_dades,resp_pos,&data_size)==TRUE){ 
                    response_mode=ISO15765_3_POSITIVE_RESPONSE; 
                    Iso15765_3IncrementResponseSize(data_size); 
                } 
            } 
            break; 
    "
    if (self.configuration_switch!=nil) then
      retinit+="#endif\n"
      ret+="#endif\n"
      retswitch+="#endif\n"
    end

    return ret,retswitch,retinit
  end
  
  def complete_c_name
    if uds_sub_service then
      ret=""+uds_sub_service.c_name+"_"+c_name
    else
      if uds_service the
        ret=""+uds_service.c_name+"_"+c_name
      else
        ret=c_name
      end
    end
    return ret
  end
  
  def complete_c_define_name
    if uds_sub_service then
      ret=""+uds_sub_service.c_define_name+"_"+c_define_name
    else
      if uds_service the
        ret=""+uds_service.c_define_name+"_"+c_define_name
      else
        ret=c_define_name
      end
    end
    return ret
  end
  
  def to_serv_fixparams_h(prev_serv_fixparams,is_bootloader=false)
    if (!is_bootloader) then
      prefix="UDS_SERV_FIXPARAMS_"
    else
      prefix="UDS_BL_SERV_FIXPARAMS_"
    end

    if (prev_serv_fixparams==nil) then
      serv_fixparams_index="((uint8_t)0)"
    else
      serv_fixparams_index="(uint8_t)("+prefix+prev_serv_fixparams.complete_c_define_name+"_INDEX+1)"
    end
    ret="\n/*  "+self.name+"  */\n"
    if (self.configuration_switch!=nil) then
      ret+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="#define "+prefix+self.complete_c_define_name+"_ID                 ((uint16_t)0x"+self.ident.upcase+")\n"
    ret+="#define "+prefix+self.complete_c_define_name+"_LEN                 ((uint8_t)"+self.length.to_s+")\n"
    ret+="#define "+prefix+self.complete_c_define_name+"_INDEX                ("+serv_fixparams_index+")\n"
    #ret+="#define "+prefix+self.complete_c_define_name+"_NUMBYTE                 ((uint8_t)(("+serv_fixparams_index+")/8))\n"
    #ret+="#define "+prefix+self.complete_c_define_name+"_BITMASK                 ((uint8_t)1<<("+serv_fixparams_index+"%8))\n"
    #ret+="\nBOOL UDSServWithFixParams_"+self.complete_c_name+"(uint8_t *data_buffer, uint8_t index, uint16_t *data_size);\n"
    
    ret+="#define "+prefix+self.c_define_name+"_SESSION_ACCESS     (((uint8_t)0x00)"
    if ((!is_bootloader and self.app_session_default) or (is_bootloader and self.boot_session_default)) then
    ret+=" | UDS_DEFAULT_SESSION_MASK"
    end
    if ((!is_bootloader and self.app_session_prog) or (is_bootloader and self.boot_session_prog)) then
    ret+=" | UDS_PROGRAMMING_SESSION_MASK"
    end
        if ((!is_bootloader and self.app_session_extended) or (is_bootloader and self.boot_session_extended)) then 
    ret+=" | UDS_EXT_DIAG_SESSION_MASK"
    end
    if ((!is_bootloader and self.app_session_supplier) or (is_bootloader and self.boot_session_supplier)) then
    ret+=" | UDS_SYSTEM_SUPPLIER_SPECIFIC_SESSION_MASK"
    end
    ret+=")\n"
        
    ret+="#define "+prefix+self.c_define_name+"_SECURITY_ACCESS     (((uint8_t)0x00)"
    if (self.sec_locked) then
    ret+=" | UDS_LOCKED_SECURITY_MASK"
    end
    if (self.sec_lev1) then
    ret+=" | UDS_L1_SECURITY_MASK"
    end
    if (self.sec_lev_11) then
    ret+=" | UDS_L11_SECURITY_MASK"
    end
    if (self.sec_supplier) then
    ret+=" | UDS_SYSTEM_SUPPLIER_SPECIFIC_SECURITY_MASK"
    end
    ret+=")\n"
    
    ret+="#define "+prefix+self.c_define_name+"_ADDRESSING_ACCESS     (((uint8_t)0x00)"
    if (self.addr_phys) then
    ret+=" | UDS_PHYSICAL_ADDRESSING_MASK"
    end
    if (self.addr_func) then
    ret+=" | UDS_FUNCTIONAL_ADDRESSING_MASK"
    end
    ret+=")\n" 
    
    if (configuration_switch!=nil) then
      #ret+="#else\n"
      #if prev_serv_fixparams!=nil then
      #  ret+="#define "+prefix+self.complete_c_define_name+"_INDEX                "+prefix+prev_serv_fixparams.complete_c_define_name+"_INDEX\n"
      #  ret+="#define "+prefix+self.complete_c_define_name+"_NUMBYTE                 "+prefix+prev_serv_fixparams.complete_c_define_name+"_NUMBYTE\n"
      #else
      #  ret+="#define "+prefix+self.complete_c_define_name+"_INDEX                ((uint8_t)0)\n"
      #  ret+="#define "+prefix+self.complete_c_define_name+"_NUMBYTE                 ((uint8_t)0)\n"
      #end
      ret+="#endif\n"
    end
    
    return ret
  end
  
  
  def to_routine_ctrl_h(is_bootloader=false)
    ret=""
    if (self.configuration_switch!=nil) then
      ret+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="BOOL UDSRoutineCtrl_"+self.complete_c_name+"(uint8_t *routine_entry_option, uint16_t size, tp_uds_routinectl resp);\n"
    if (self.configuration_switch!=nil) then
      ret+="#endif\n"
    end
    
    return ret
  end
  
  def to_routine_ctrl_c(index,is_bootloader=false)
    
    if (!is_bootloader) then
      prefix="UDS_SERV_FIXPARAMS_"
    else
      prefix="UDS_BL_SERV_FIXPARAMS_"
    end

    retinit="\n\t/*  "+self.complete_c_name+"  */\n"
    ret="\n/*  "+self.complete_c_name+"  */\n"
    retswitch="\n\t/*  "+self.complete_c_name+"  */\n"
    if (self.configuration_switch!=nil) then
      retinit+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
      ret+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
      retswitch+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
    end

    ret+="BOOL UDSRoutineCtrl_"+self.complete_c_name+"(uint8_t *routine_entry_option, uint16_t size, tp_uds_routinectl resp)\n{\n"
    ret+="\t/* TODO: fill this */ \n\treturn TRUE;\n"
    ret+="}\n"
    

    retswitch += "\telse if (id=="+prefix+self.complete_c_define_name+"_ID)\n\t{
            if (UDS_check_permissions("+prefix+self.c_define_name+"_SESSION_ACCESS,"+prefix+self.c_define_name+"_SECURITY_ACCESS ,"+prefix+self.c_define_name+"_ADDRESSING_ACCESS ,&response_mode)==TRUE)
            { 
                response_mode=UDSRoutineCtrl_"+self.complete_c_name+"(routine_entry_option, size, resp);
            } 
        }
      "
    
    if (self.configuration_switch!=nil) then
      retinit+="#endif\n"
      ret+="#endif\n"
      retswitch+="#endif\n"
    end

    return ret,retswitch,retinit
  end
  
  def boolean_to_s(value)
    if value==true then
      "TRUE"
    else
      "FALSE"
    end
  end
  
  def c_name
    name.downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '').gsub('-','_')
  end
  
  def c_define_name
    c_name.upcase
  end

  
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end

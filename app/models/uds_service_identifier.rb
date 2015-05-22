class UdsServiceIdentifier < ActiveRecord::Base

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
    timestamps
  end
  attr_accessible :ident, :name, :length, :app_session_default, :app_session_prog, :app_session_extended, :app_session_supplier, :boot_session_default, :boot_session_prog, :boot_session_extended, :boot_session_supplier, :sec_locked, :sec_lev1, :sec_lev_11, :sec_supplier, :addr_phys, :addr_func, :supress_bit, :precondition, :uds_service_sub, :uds_sub_service_id, :configuration_switch_id, :configuration_switch

  belongs_to :uds_sub_service, :inverse_of => :uds_service_identifiers
  belongs_to :uds_service, :creator => :true, :inverse_of => :uds_service_identifiers
  belongs_to :configuration_switch, :inverse_of => :uds_service_identifiers

  def to_rdi_c(index)
    
    retinit="\n\t/*  "+self.name+"  */\n"
    ret="\n/*  "+self.name+"  */\n"
    retswitch="\n\t/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      retinit+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      retswitch+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end

    if (self.app_session_default) then
      retinit+="\tuds_rdi_permission_session_default[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.app_session_prog) then
      retinit+="\tuds_rdi_permission_session_prog[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.app_session_extended) then
      retinit+="\tuds_rdi_permission_session_extended[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.app_session_supplier) then
      retinit+="\tuds_rdi_permission_session_supplier[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_locked) then
      retinit+="\tuds_rdi_permission_security_locked[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev1) then
      retinit+="\tuds_rdi_permission_security_level1[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev_11) then
      retinit+="\tuds_rdi_permission_security_level11[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_supplier) then
      retinit+="\tuds_rdi_permission_security_supplier[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_phys) then
      retinit+="\tuds_rdi_permission_addressing_physical[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_func) then
      retinit+="\tuds_rdi_permission_addressing_functional[UDS_RDI_"+self.c_define_name+"_NUMBYTE]|=UDS_RDI_"+self.c_define_name+"_BITMASK;\n"
    end

    ret+="BOOL UDSRdi_"+self.c_name+"(UI_8 *data_buffer, UI_8 index, UI_8 *data_size)\n{\n"
    ret+="\t/* TODO: fill this */ \n\treturn TRUE;\n"
    ret+="}\n"
    retswitch +="        case UDS_RDI_"+self.c_define_name+"_ID: 
            if (UDSRdi_check_permissions(UDS_RDI_"+self.c_define_name+"_NUMBYTE,UDS_RDI_"+self.c_define_name+"_BITMASK ,&response_mode)==TRUE){ 
                if (UDSRdi_"+self.c_name+"(resp->buffer_dades,resp_pos,&data_size)==TRUE){ 
                    response_mode=ISO15765_3_POSITIVE_RESPONSE; 
                    Iso15765_3IncrementResponseSize(data_size); 
                } 
            } 
            break; 
    "
    if (configuration_switch!=nil) then
      retinit+="#endif\n"
      ret+="#endif\n"
      retswitch+="#endif\n"
    end

    return ret,retswitch,retinit
  end
  
  def to_rdi_h(prev_rdi)
    if (prev_rdi==nil) then
      rdi_index="((UI_8)0)"
    else
      rdi_index="(UI_8)(UDS_RDI_"+prev_rdi.c_define_name+"_INDEX+1)"
    end
    ret="\n/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="#define UDS_RDI_"+self.c_define_name+"_ID                 ((UI_16)0x"+self.ident.upcase+")\n"
    ret+="#define UDS_RDI_"+self.c_define_name+"_LEN                 ((UI_8)"+self.length.to_s+")\n"
    ret+="#define UDS_RDI_"+self.c_define_name+"_INDEX                ("+rdi_index+")\n"
    ret+="#define UDS_RDI_"+self.c_define_name+"_NUMBYTE                 ((UI_8)(("+rdi_index+")/8))\n"
    ret+="#define UDS_RDI_"+self.c_define_name+"_BITMASK                 ((UI_8)1<<("+rdi_index+"%8))\n"
    ret+="\nBOOL UDSRdi_"+self.c_name+"(UI_8 *data_buffer, UI_8 index, UI_8 *data_size);\n"
    if (configuration_switch!=nil) then
      ret+="#else\n"
      if prev_rdi!=nil then
        ret+="#define UDS_RDI_"+self.c_define_name+"_INDEX                UDS_RDI_"+prev_rdi.c_define_name+"_INDEX\n"
        ret+="#define UDS_RDI_"+self.c_define_name+"_NUMBYTE                 UDS_RDI_"+prev_rdi.c_define_name+"_NUMBYTE\n"
      else
        ret+="#define UDS_RDI_"+self.c_define_name+"_INDEX                ((UI_8)0)\n"
        ret+="#define UDS_RDI_"+self.c_define_name+"_NUMBYTE                 ((UI_8)0)\n"
      end
      ret+="#endif\n"
    end
    
    return ret
  end
  
  def boolean_to_s(value)
    if value==true then
      "TRUE"
    else
      "FALSE"
    end
  end
  
  def to_wdi_c(index)
    
    retinit="\n\t/*  "+self.name+"  */\n"
    ret="\n/*  "+self.name+"  */\n"
    retswitch="\n\t/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      retinit+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      retswitch+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end

    if (self.app_session_default) then
      retinit+="\tuds_wdi_permission_session_default[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.app_session_prog) then
      retinit+="\tuds_wdi_permission_session_prog[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.app_session_extended) then
      retinit+="\tuds_wdi_permission_session_extended[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.app_session_supplier) then
      retinit+="\tuds_wdi_permission_session_supplier[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_locked) then
      retinit+="\tuds_wdi_permission_security_locked[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev1) then
      retinit+="\tuds_wdi_permission_security_level1[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev_11) then
      retinit+="\tuds_wdi_permission_security_level11[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_supplier) then
      retinit+="\tuds_wdi_permission_security_supplier[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_phys) then
      retinit+="\tuds_wdi_permission_addressing_physical[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_func) then
      retinit+="\tuds_wdi_permission_addressing_functional[UDS_WDI_"+self.c_define_name+"_NUMBYTE]|=UDS_WDI_"+self.c_define_name+"_BITMASK;\n"
    end

    ret+="BOOL UDSWdi_"+self.c_name+"(UI_8 *response_mode, UI_8 *buf_data_rx, UI_8 size)\n{\n"
    ret+="\tif (size < UDS_WDI_"+self.c_define_name+"_LEN){\n"
    ret+="\t\t*response_mode = UDS_ERR_INVALID_FORMAT;\n"
    ret+="\t} else {\n"
    ret+="\t\t*response_mode = CheckStartWriteEepromProg(UDS_WDI_"+self.c_define_name+"_ADDR, buf_data_rx, UDS_WDI_"+self.c_define_name+"_LEN, TRUE);\n"
    ret+="\t}\n\n"
    ret+="\treturn TRUE;\n"
    ret+="}\n\n"
    
    retswitch += "        case UDS_WDI_"+self.c_define_name+"_ID: 
            if (UDSWdi_check_permissions(UDS_WDI_"+self.c_define_name+"_NUMBYTE,UDS_WDI_"+self.c_define_name+"_BITMASK ,&response_mode) == TRUE)
            {
                UDSWdi_"+self.c_name+"(&response_mode, buf_data_rx, size);
            }
            break;
\n"
    if (configuration_switch!=nil) then
      retinit+="#endif\n"
      ret+="#endif\n"
      retswitch+="#endif\n"
    end

    return ret,retswitch,retinit
  end
  
  def to_wdi_h(prev_wdi)
    if (prev_wdi==nil) then
      rdi_index="((UI_8)0)"
    else
      rdi_index="(UI_8)(UDS_WDI_"+prev_wdi.c_define_name+"_INDEX+1)"
    end
    ret="\n/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="#define UDS_WDI_"+self.c_define_name+"_ID                 ((UI_16)0x"+self.ident.upcase+")\n"
    ret+="#define UDS_WDI_"+self.c_define_name+"_LEN                 ((UI_8)"+self.length.to_s+")\n"
    ret+="#define UDS_WDI_"+self.c_define_name+"_INDEX                ("+rdi_index+")\n"
    ret+="#define UDS_WDI_"+self.c_define_name+"_NUMBYTE                 ((UI_8)(("+rdi_index+")/8))\n"
    ret+="#define UDS_WDI_"+self.c_define_name+"_BITMASK                 ((UI_8)1<<("+rdi_index+"%8))\n"
    ret+="BOOL UDSWdi_"+self.c_name+"(UI_8 *response_mode, UI_8 *buf_data_rx, UI_8 size);\n"
    if (configuration_switch!=nil) then
      ret+="#else\n"
      if prev_wdi!=nil then
        ret+="#define UDS_WDI_"+self.c_define_name+"_INDEX                UDS_WDI_"+prev_wdi.c_define_name+"_INDEX\n"
        ret+="#define UDS_WDI_"+self.c_define_name+"_NUMBYTE                 UDS_WDI_"+prev_wdi.c_define_name+"_NUMBYTE\n"
      else
        ret+="#define UDS_WDI_"+self.c_define_name+"_INDEX                ((UI_8)0)\n"
        ret+="#define UDS_WDI_"+self.c_define_name+"_NUMBYTE                 ((UI_8)0)\n"
      end
      ret+="#endif\n"
    end
    
    if (prev_wdi!=nil) then
      previous_mem="UDS_WDI_"+prev_wdi.c_define_name+"_ADDR"
    else
      previous_mem="EEPROM_FACTORY_ZONE_OFFSET"
    end
    retmem="#define UDS_WDI_"+self.c_define_name+"_ADDR                 ("+previous_mem+"+UDS_WDI_"+self.c_define_name+"_LEN)\n"
    return ret,retmem
 
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

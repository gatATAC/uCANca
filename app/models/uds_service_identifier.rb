class UdsServiceIdentifier < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident                 :string
    name                  :string
    length                :integer       #length is the length of the identifier
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
    data_size             :integer
    custom_code           :text
    generate :boolean, :default => true
    timestamps
  end
  attr_accessible :ident, :name, :length, :app_session_default, :app_session_prog, :app_session_extended, :app_session_supplier, :boot_session_default, :boot_session_prog, :boot_session_extended, :boot_session_supplier, :sec_locked, :sec_lev1, :sec_lev_11, :sec_supplier, :addr_phys, :addr_func, :supress_bit, :precondition, :uds_service_sub, :uds_sub_service_id, :configuration_switch_id, :configuration_switch, :data_size, :custom_code, :generate

  belongs_to :uds_sub_service, :inverse_of => :uds_service_identifiers
  belongs_to :uds_service, :creator => :true, :inverse_of => :uds_service_identifiers
  belongs_to :configuration_switch, :inverse_of => :uds_service_identifiers

  def to_rdi_c(index,is_bootloader=false)
    if (!is_bootloader) then
      prefix="UDS_RDI_"
    else
      prefix="UDS_BL_RDI_"
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
      retinit+="\tuds_rdi_permission_session_default["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_prog) or (is_bootloader and self.boot_session_prog)) then
      retinit+="\tuds_rdi_permission_session_prog["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
        if ((!is_bootloader and self.app_session_extended) or (is_bootloader and self.boot_session_extended)) then 
      retinit+="\tuds_rdi_permission_session_extended["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_supplier) or (is_bootloader and self.boot_session_supplier)) then
      retinit+="\tuds_rdi_permission_session_supplier["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_locked) then
      retinit+="\tuds_rdi_permission_security_locked["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev1) then
      retinit+="\tuds_rdi_permission_security_level1["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev_11) then
      retinit+="\tuds_rdi_permission_security_level11["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_supplier) then
      retinit+="\tuds_rdi_permission_security_supplier["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_phys) then
      retinit+="\tuds_rdi_permission_addressing_physical["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_func) then
      retinit+="\tuds_rdi_permission_addressing_functional["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end

    ret+="static BOOL UDSRdi_"+self.c_name+"(uint8_t *data_buffer, uint16_t index, uint16_t *data_size)\n{\n"
    
    if (custom_code && custom_code.size>0)
      ret+="\t"+custom_code+"\n"
    else
      ret+="\tEepromRead("+prefix+self.c_define_name+"_ADDR, &(data_buffer[index]), "+prefix+self.c_define_name+"_DATA_SIZE);\n"
      ret+="\t*data_size="+prefix+self.c_define_name+"_DATA_SIZE;\n\treturn TRUE;\n"
      #ret+="\t/* TODO: fill this */ \n\treturn TRUE;\n"
    end
    
    ret+="}\n"
    retswitch +="        case "+prefix+self.c_define_name+"_ID: 
            if (UDS_check_permissions("+prefix+self.c_define_name+"_SESSION_ACCESS,"+prefix+self.c_define_name+"_SECURITY_ACCESS ,"+prefix+self.c_define_name+"_ADDRESSING_ACCESS ,&response_mode)==TRUE){ 
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
  
  def to_rdi_h(prev_rdi,is_bootloader=false)
    if (!is_bootloader) then
      prefix="UDS_RDI_"
    else
      prefix="UDS_BL_RDI_"
      prefix_rdi="UDS_RDI_"
    end    
    if (prev_rdi==nil) then
      rdi_index="((uint8_t)0)"
    else
      rdi_index="(uint8_t)("+prefix+prev_rdi.c_define_name+"_INDEX+1)"
    end
    ret="\n/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="#define "+prefix+self.c_define_name+"_ID                 ((uint16_t)0x"+self.ident.upcase+")\n"
    ret+="#define "+prefix+self.c_define_name+"_LEN                 ((uint8_t)"+self.length.to_s+")\n"
    ret+="#define "+prefix+self.c_define_name+"_DATA_SIZE           ((uint16_t)"+self.data_size.to_s+")\n"
    ret+="#define "+prefix+self.c_define_name+"_INDEX                ("+rdi_index+")\n"
    # ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 ((uint8_t)("+prefix+self.c_define_name+"_INDEX/8))\n"
    # ret+="#define "+prefix+self.c_define_name+"_BITMASK                 ((uint8_t)1<<("+prefix+self.c_define_name+"_INDEX%8))\n"
    # ret+="\nBOOL UDSRdi_"+self.c_name+"(uint8_t *data_buffer, uint16_t index, uint16_t *data_size);\n"
        
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

    
    if (self.configuration_switch!=nil) then
      #ret+="#else\n"
      #if prev_rdi!=nil then
      #  ret+="#define "+prefix+self.c_define_name+"_INDEX                "+prefix+prev_rdi.c_define_name+"_INDEX\n"
      #  ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 "+prefix+prev_rdi.c_define_name+"_NUMBYTE\n"
      #else
      #  ret+="#define "+prefix+self.c_define_name+"_INDEX                ((uint8_t)-1)\n"
      #  ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 ((uint8_t)0)\n"
      #end
      ret+="#endif\n"
    end

    retmem=""
    
    if (is_bootloader) then
    # Normalmente todos los WDI son también RDI...
    retmem="#define "+prefix+self.c_define_name+"_ADDR ("+prefix_rdi+self.c_define_name+"_ADDR)"
    end
    
    return ret,retmem    

  end
  
  def boolean_to_s(value)
    if value==true then
      "TRUE"
    else
      "FALSE"
    end
  end
  
  def to_wdi_c(index,is_bootloader=false)
    
    if (!is_bootloader) then
      prefix="UDS_WDI_"
    else
      prefix="UDS_BL_WDI_"
    end    
    retinit="\n\t/*  "+self.name+"  */\n"
    ret="\n/*  "+self.name+"  */\n"
    retswitch="\n\t/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      retinit+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      retswitch+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end

    if ((!is_bootloader and self.app_session_default) or (is_bootloader and self.boot_session_default)) then
      retinit+="\tuds_wdi_permission_session_default["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_prog) or (is_bootloader and self.boot_session_prog)) then
      retinit+="\tuds_wdi_permission_session_prog["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
        if ((!is_bootloader and self.app_session_extended) or (is_bootloader and self.boot_session_extended)) then 
      retinit+="\tuds_wdi_permission_session_extended["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_supplier) or (is_bootloader and self.boot_session_supplier)) then
      retinit+="\tuds_wdi_permission_session_supplier["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_locked) then
      retinit+="\tuds_wdi_permission_security_locked["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev1) then
      retinit+="\tuds_wdi_permission_security_level1["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev_11) then
      retinit+="\tuds_wdi_permission_security_level11["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_supplier) then
      retinit+="\tuds_wdi_permission_security_supplier["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_phys) then
      retinit+="\tuds_wdi_permission_addressing_physical["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_func) then
      retinit+="\tuds_wdi_permission_addressing_functional["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end

      ret+="static BOOL UDSWdi_"+self.c_name+"(uint8_t *response_mode, uint8_t *buf_data_rx, uint16_t size)\n{\n"
    if (custom_code && custom_code.size>0)
      ret+="\t"+custom_code+"\n"
    else
      ret+="\tif (size != "+prefix+self.c_define_name+"_DATA_SIZE){\n"
      ret+="\t\t*response_mode = UDS_ERR_INVALID_FORMAT;\n"
      ret+="\t} else {\n"
if is_bootloader then
      ret+="\t\t*response_mode = CheckStartWriteEepromProgBl("+prefix+self.c_define_name+"_ADDR, buf_data_rx, "+prefix+self.c_define_name+"_DATA_SIZE, TRUE);\n"
else
      ret+="\t\t*response_mode = CheckStartWriteEepromProg("+prefix+self.c_define_name+"_ADDR, buf_data_rx, "+prefix+self.c_define_name+"_DATA_SIZE, TRUE);\n"
end
ret+="\t}\n\n"
      ret+="\treturn TRUE;\n"
    end
      ret+="}\n\n"
    
    retswitch += "        case "+prefix+self.c_define_name+"_ID: 
            if (UDS_check_permissions("+prefix+self.c_define_name+"_SESSION_ACCESS,"+prefix+self.c_define_name+"_SECURITY_ACCESS ,"+prefix+self.c_define_name+"_ADDRESSING_ACCESS ,&response_mode)==TRUE)
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
  
  def to_wdi_h(prev_wdi,is_bootloader=false)
    if (!is_bootloader) then
      prefix="UDS_WDI_"
      prefix_rdi="UDS_RDI_"
    else
      prefix="UDS_BL_WDI_"
      prefix_rdi="UDS_BL_RDI_"
    end    
    if (prev_wdi==nil) then
      rdi_index="((uint8_t)0)"
    else
      rdi_index="(uint8_t)("+prefix+prev_wdi.c_define_name+"_INDEX+1)"
    end
    ret="\n/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="#define "+prefix+self.c_define_name+"_ID                 ((uint16_t)0x"+self.ident.upcase+")\n"
    ret+="#define "+prefix+self.c_define_name+"_LEN                 ((uint8_t)"+self.length.to_s+")\n"
    ret+="#ifdef "+prefix_rdi+self.c_define_name+"_DATA_SIZE\n"
    ret+="#define "+prefix+self.c_define_name+"_DATA_SIZE ("+prefix_rdi+self.c_define_name+"_DATA_SIZE)\n"
    ret+="#else\n"
    ret+="#define "+prefix+self.c_define_name+"_DATA_SIZE                 ((uint16_t)"+self.data_size.to_s+")\n"
    ret+="#endif\n"
    ret+="#define "+prefix+self.c_define_name+"_INDEX                ("+rdi_index+")\n"
    #ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 ((uint8_t)("+prefix+self.c_define_name+"_INDEX /8))\n"
    #ret+="#define "+prefix+self.c_define_name+"_BITMASK                 ((uint8_t)1<<("+prefix+self.c_define_name+"_INDEX %8))\n"
    #ret+="BOOL UDSWdi_"+self.c_name+"(uint8_t *response_mode, uint8_t *buf_data_rx, uint16_t size);\n"
    
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
      #if prev_wdi!=nil then
        #ret+="#define "+prefix+self.c_define_name+"_INDEX                "+prefix+prev_wdi.c_define_name+"_INDEX\n"
        #ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 "+prefix+prev_wdi.c_define_name+"_NUMBYTE\n"
      #else
        #ret+="#define "+prefix+self.c_define_name+"_INDEX                ((uint8_t)-1)\n"
        #ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 ((uint8_t)0)\n"
      #end
      ret+="#endif\n"
    end

    # Esto queda aquí por si queremos hacer una definición automática de las posiciones de memoria de los WDI
=begin

    if (prev_wdi!=nil) then
      previous_mem=""+prefix+prev_wdi.c_define_name+"_ADDR"
    else
      previous_mem="EEPROM_FACTORY_ZONE_OFFSET"
    end
    retmem="#define "+prefix+self.c_define_name+"_ADDR                 ("+previous_mem+"+"+prefix+self.c_define_name+"_DATA_SIZE)\n"
=end
    
    # Normalmente todos los WDI son también RDI...
    retmem="#define "+prefix+self.c_define_name+"_ADDR ("+prefix_rdi+self.c_define_name+"_ADDR)"


    return ret,retmem
 
  end
  
  def c_name
    #name.downcase.strip.gsub(' ', '_').gsub(/[^\w-]/, '').gsub('-','_')
    ident.downcase
  end
  
  def c_define_name
    c_name.upcase
  end

    def to_ioctl_c(index,is_bootloader=false)
    if (!is_bootloader) then
      prefix="UDS_IOCTL_"
    else
      prefix="UDS_BL_IOCTL_"
    end        
    retinit="\n\t/*  "+self.name+"  */\n"
    ret="\n/*  "+self.name+"  */\n"
    retswitch="\n\t/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      retinit+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      retswitch+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end

    if ((!is_bootloader and self.app_session_default) or (is_bootloader and self.boot_session_default)) then
      retinit+="\tuds_ioctl_permission_session_default["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_prog) or (is_bootloader and self.boot_session_prog)) then
      retinit+="\tuds_ioctl_permission_session_prog["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
        if ((!is_bootloader and self.app_session_extended) or (is_bootloader and self.boot_session_extended)) then 
      retinit+="\tuds_ioctl_permission_session_extended["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_supplier) or (is_bootloader and self.boot_session_supplier)) then
      retinit+="\tuds_ioctl_permission_session_supplier["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_locked) then
      retinit+="\tuds_ioctl_permission_security_locked["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev1) then
      retinit+="\tuds_ioctl_permission_security_level1["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev_11) then
      retinit+="\tuds_ioctl_permission_security_level11["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_supplier) then
      retinit+="\tuds_ioctl_permission_security_supplier["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_phys) then
      retinit+="\tuds_ioctl_permission_addressing_physical["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_func) then
      retinit+="\tuds_ioctl_permission_addressing_functional["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end

    ret+="uint8_t UDSIOCtrl_"+self.c_name+"(uint8_t ctrl_type, uint8_t ctrl_state, uint8_t *buf_data_rx, uint16_t size)\n{\n"
    
    if (custom_code && custom_code.size>0)
      ret+="\t"+custom_code+"\n"
    else
      ret+="\tEepromRead("+prefix+self.c_define_name+"_ADDR, (data_buffer + index), "+prefix+self.c_define_name+"_DATA_SIZE);\n"
      ret+="\t*data_size="+prefix+self.c_define_name+"_DATA_SIZE;\n\treturn TRUE;\n"
      #ret+="\t/* TODO: fill this */ \n\treturn TRUE;\n"
    end
    
    ret+="}\n"
    retswitch +="        case "+prefix+self.c_define_name+"_ID: 
            if (UDSIOCtrl_check_permissions("+prefix+self.c_define_name+"_NUMBYTE,"+prefix+self.c_define_name+"_BITMASK ,&response_mode)==TRUE){ 
                response_mode=UDSIOCtrl_"+self.c_name+"(ctr_type, ctrl_state, buf_data_rx, size); 
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
  
  def to_ioctl_h(prev_ioctl,is_bootloader=false)
    if (!is_bootloader) then
      prefix="UDS_IOCTL_"
    else
      prefix="UDS_BL_IOCTL_"
    end        
    if (prev_ioctl==nil) then
      ioctl_index="((uint8_t)0)"
    else
      ioctl_index="(uint8_t)("+prefix+prev_ioctl.c_define_name+"_INDEX+1)"
    end
    ret="\n/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="#define "+prefix+self.c_define_name+"_ID                 ((uint16_t)0x"+self.ident.upcase+")\n"
    ret+="#define "+prefix+self.c_define_name+"_LEN                 ((uint8_t)"+self.length.to_s+")\n"
    ret+="#define "+prefix+self.c_define_name+"_INDEX                ("+ioctl_index+")\n"
    ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 ((uint8_t)("+prefix+self.c_define_name+"_INDEX/8))\n"
    ret+="#define "+prefix+self.c_define_name+"_BITMASK                 ((uint8_t)1<<("+prefix+self.c_define_name+"_INDEX%8))\n"
    ret+="#define UDS_IOCLT_CHECK_AT_LEAST_ONE"
    ret+="\n\tuint8_t UDSIOCtrl_"+self.c_name+"(uint8_t ctrl_type, uint8_t ctrl_state, uint8_t *buf_data_rx, uint16_t size);\n\n"
    if (configuration_switch!=nil) then
      ret+="#else\n"
      if prev_ioctl!=nil then
        ret+="#define "+prefix+self.c_define_name+"_INDEX                "+prefix+prev_ioctl.c_define_name+"_INDEX\n"
        ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 "+prefix+prev_ioctl.c_define_name+"_NUMBYTE\n"
      else
        ret+="#define "+prefix+self.c_define_name+"_INDEX                ((uint8_t)-1)\n"
        ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 ((uint8_t)0)\n"
      end
      ret+="#endif\n"
    end
    
    return ret
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

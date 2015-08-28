class UdsService < ActiveRecord::Base

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
    generate              :boolean, :default => true    
    timestamps
  end
  attr_accessible :ident, :name, :length, :app_session_default, :app_session_prog, :app_session_extended, :app_session_supplier, :boot_session_default, :boot_session_prog, :boot_session_extended, :boot_session_supplier, :sec_locked, :sec_lev1, :sec_lev_11, :sec_supplier, :addr_phys, :addr_func, :supress_bit, :precondition, :configuration_switch, :configuration_switch_id

  belongs_to :project, :creator => :true, :inverse_of => :uds_services
  belongs_to :configuration_switch, :inverse_of => :uds_services

  has_many :uds_sub_services, :dependent => :destroy, :inverse_of => :uds_service
  has_many :uds_service_fixed_params, :dependent => :destroy, :inverse_of => :uds_service
  has_many :uds_service_identifiers, :dependent => :destroy, :inverse_of => :uds_service

  validates :project, :presence => :true
  
  children :uds_sub_services

  
  def to_serv_c(index,is_bootloader=false)
    retinit="\n\t/*  "+self.name+"  */\n"
    ret="\n/*  "+self.name+"  */\n"
    retswitch="\n\t/*  "+self.name+"  */\n"
    if (self.configuration_switch!=nil) then
      retinit+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
      ret+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
      retswitch+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
    end
    if (!is_bootloader) then
      prefix="UDS_SERV_"
    else
      prefix="UDS_BL_SERV_"
    end

    if ((!is_bootloader and self.app_session_default) or (is_bootloader and self.boot_session_default)) then
      retinit+="\tuds_serv_permission_session_default["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_prog) or (is_bootloader and self.boot_session_prog)) then
      retinit+="\tuds_serv_permission_session_prog["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_extended) or (is_bootloader and self.boot_session_extended)) then
      retinit+="\tuds_serv_permission_session_extended["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_supplier) or (is_bootloader and self.boot_session_supplier)) then
      retinit+="\tuds_serv_permission_session_supplier["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_locked) then
      retinit+="\tuds_serv_permission_security_locked["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev1) then
      retinit+="\tuds_serv_permission_security_level1["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev_11) then
      retinit+="\tuds_serv_permission_security_level11["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_supplier) then
      retinit+="\tuds_serv_permission_security_supplier["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_phys) then
      retinit+="\tuds_serv_permission_addressing_physical["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_func) then
      retinit+="\tuds_serv_permission_addressing_functional["+prefix+self.c_define_name+"_NUMBYTE]|="+prefix+self.c_define_name+"_BITMASK;\n"
    end

    ret+="BOOL UDSServ_"+self.c_name+"(uint8_t *data_buffer, uint8_t index, uint16_t *data_size)\n{\n"
    ret+="\t/* TODO: fill this */ \n\treturn TRUE;\n"
    ret+="}\n"
    retswitch +="        case "+prefix+self.c_define_name+"_ID: 
            if (UDSServ_check_permissions("+prefix+self.c_define_name+"_NUMBYTE,"+prefix+self.c_define_name+"_BITMASK ,&response_mode)==TRUE){ 
                if (UDSServ_"+self.c_name+"(resp->buffer_dades,resp_pos,&data_size)==TRUE){ 
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
  
  
  def configuration_switch
    nil
  end
    
  def to_serv_h(prev_serv,is_bootloader=false)
    if (!is_bootloader) then
      prefix="UDS_SERV_"
    else
      prefix="UDS_BL_SERV_"
    end
    if (prev_serv==nil) then
      serv_index="((uint8_t)0)"
    else
      serv_index="(uint8_t)("+prefix+prev_serv.c_define_name+"_INDEX+1)"
    end
    ret="\n/*  "+self.name+"  */\n"
    if (self.configuration_switch!=nil) then
      ret+="#ifdef "+self.configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="#define "+prefix+self.c_define_name+"_ID                 ((uint16_t)0x"+self.ident.upcase+")\n"
    ret+="#define "+prefix+self.c_define_name+"_LEN                 ((uint8_t)"+self.length.to_s+")\n"
    ret+="#define "+prefix+self.c_define_name+"_INDEX                ("+serv_index+")\n"
    ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 ((uint8_t)(("+serv_index+")/8))\n"
    ret+="#define "+prefix+self.c_define_name+"_BITMASK                 ((uint8_t)1<<("+serv_index+"%8))\n"
    ret+="\nBOOL UDSService_"+self.c_name+"(uint8_t *data_buffer, uint8_t index, uint16_t *data_size);\n"
    if (self.configuration_switch!=nil) then
      ret+="#else\n"
      if prev_serv!=nil then
        ret+="#define "+prefix+self.c_define_name+"_INDEX                "+prefix+prev_serv.c_define_name+"_INDEX\n"
        ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 "+prefix+prev_serv.c_define_name+"_NUMBYTE\n"
      else
        ret+="#define "+prefix+self.c_define_name+"_INDEX                ((uint8_t)0)\n"
        ret+="#define "+prefix+self.c_define_name+"_NUMBYTE                 ((uint8_t)0)\n"
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

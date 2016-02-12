
class UdsSubService < ActiveRecord::Base

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
  attr_accessible :ident, :name, :length, :app_session_default, :app_session_prog, :app_session_extended, :app_session_supplier, :boot_session_default, :boot_session_prog, :boot_session_extended, :boot_session_supplier, :sec_locked, :sec_lev1, :sec_lev_11, :sec_supplier, :addr_phys, :addr_func, :supress_bit, :precondition, :uds_service, :uds_service_id, :configuration_switch, :configuration_switch_id

  belongs_to :uds_service, :creator => :true, :inverse_of => :uds_sub_services
  belongs_to :configuration_switch, :inverse_of => :uds_sub_services

  has_many :uds_service_fixed_params, :inverse_of => :uds_sub_service
  has_many :uds_service_identifiers, :dependent => :destroy, :inverse_of => :uds_sub_service

  children :uds_service_fixed_params, :uds_service_identifiers

  validates :uds_service, :presence => :true
    
  def to_sub_serv_c(index,is_bootloader=false)
    
    retinit="\n\t/*  "+self.name+"  */\n"
    ret="\n/*  "+self.name+"  */\n"
    retswitch="\n\t/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      retinit+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
      retswitch+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end

    if ((!is_bootloader and self.app_session_default) or (is_bootloader and self.boot_session_default)) then
      retinit+="\tuds_sub_serv_permission_session_default[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_prog) or (is_bootloader and self.boot_session_prog)) then
      retinit+="\tuds_sub_serv_permission_session_prog[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
        if ((!is_bootloader and self.app_session_extended) or (is_bootloader and self.boot_session_extended)) then 
      retinit+="\tuds_sub_serv_permission_session_extended[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
    if ((!is_bootloader and self.app_session_supplier) or (is_bootloader and self.boot_session_supplier)) then
      retinit+="\tuds_sub_serv_permission_session_supplier[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_locked) then
      retinit+="\tuds_sub_serv_permission_security_locked[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev1) then
      retinit+="\tuds_sub_serv_permission_security_level1[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_lev_11) then
      retinit+="\tuds_sub_serv_permission_security_level11[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.sec_supplier) then
      retinit+="\tuds_sub_serv_permission_security_supplier[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_phys) then
      retinit+="\tuds_sub_serv_permission_addressing_physical[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end
    if (self.addr_func) then
      retinit+="\tuds_sub_serv_permission_addressing_functional[UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE]|=UDS_SUBSERV_"+self.c_define_name+"_BITMASK;\n"
    end

    ret+="BOOL UDSSubServ_"+self.c_name+"(uint8_t *data_buffer, uint8_t index, uint16_t *data_size)\n{\n"
    ret+="\t/* TODO: fill this */ \n\treturn TRUE;\n"
    ret+="}\n"
    retswitch +="        case UDS_SUBSERV_"+self.c_define_name+"_ID: 
            if (UDSSubServ_check_permissions(UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE,UDS_SUBSERV_"+self.c_define_name+"_BITMASK ,&response_mode)==TRUE){ 
                if (UDSSubServ_"+self.c_name+"(data_buffer,resp_pos,&data_size)==TRUE){ 
                    /* Generate positive response */ 
                    /* Increment response size in data_size */ 
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
  
  def to_sub_serv_h(prev_sub_serv,is_bootloader=false)
    if (prev_sub_serv==nil) then
      sub_serv_index="((uint8_t)0)"
    else
      sub_serv_index="(uint8_t)(UDS_SUBSERV_"+prev_sub_serv.c_define_name+"_INDEX+1)"
    end
    ret="\n/*  "+self.name+"  */\n"
    if (configuration_switch!=nil) then
      ret+="#ifdef "+configuration_switch.ident.upcase+"_ENABLED\n"
    end
    ret+="#define UDS_SUBSERV_"+self.c_define_name+"_ID                 ((uint16_t)0x"+self.ident.upcase+"U)\n"
    ret+="#define UDS_SUBSERV_"+self.c_define_name+"_LEN                 ((uint8_t)"+self.length.to_s+")\n"
    ret+="#define UDS_SUBSERV_"+self.c_define_name+"_INDEX                ("+sub_serv_index+")\n"
    ret+="#define UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE                 ((uint8_t)(("+sub_serv_index+")/8))\n"
    ret+="#define UDS_SUBSERV_"+self.c_define_name+"_BITMASK                 ((uint8_t)1<<("+sub_serv_index+"%8))\n"
    ret+="\nBOOL UDSSubServ_"+self.c_name+"(uint8_t *data_buffer, uint8_t index, uint16_t *data_size);\n"
    if (configuration_switch!=nil) then
      ret+="#else\n"
      if prev_sub_serv!=nil then
        ret+="#define UDS_SUBSERV_"+self.c_define_name+"_INDEX                UDS_SUBSERV_"+prev_sub_serv.c_define_name+"_INDEX\n"
        ret+="#define UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE                 UDS_SUBSERV_"+prev_sub_serv.c_define_name+"_NUMBYTE\n"
      else
        ret+="#define UDS_SUBSERV_"+self.c_define_name+"_INDEX                ((uint8_t)0)\n"
        ret+="#define UDS_SUBSERV_"+self.c_define_name+"_NUMBYTE                 ((uint8_t)0)\n"
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
    name.strip.gsub(' ', '').gsub(/[^\w-]/, '').gsub('-','_').camelize
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

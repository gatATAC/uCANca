class FailSafeCommand < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    feedback_required :boolean, :default => true
    timestamps
  end
  attr_accessible :name, :description, :feedback_required

  has_many :fault_fail_safe_commands, :dependent => :destroy, :inverse_of => :fail_safe_command
  has_many :faults, :through => :fault_fail_safe_commands  
  
  belongs_to :project, :creator => :true
  
  children :faults
  
  ################ Code generation


  def to_structure
    ret="\n/* "
    ret+=self.name+": "+self.description
    ret+=" */\n"
    ret+="t_"+self.name+" _"+self.name+";"
    return ret
  end

  def to_structure_define
    ret="#define "+self.name+" ad_output._"+self.name+"\n"
    return ret
  end

  def to_autodiag_main_c
    ret="\t"+self.name+".req=FALSE;\n"
    ret+="\t"+self.name+".untimed_counter=0;\n"
    ret+="\t"+self.name+".timed_counter=0;\n"
    ret+="\t"+self.name+".current_timer=0;\n"
  end

  def to_autodiag_main_c_decrement
    ret="\ttick_failsafe_command(&"+self.name+");\n"
  end

  def to_a2l
=begin
    ret="/begin MEASUREMENT "+self.name+" \"\"\n"
    ret+="UBYTE Boolean 0 0 0 1\n"
    ret+="BYTE_ORDER MSB_FIRST\n"
    ret+="ECU_ADDRESS 0x00000000\n"
    ret+="ECU_ADDRESS_EXTENSION 0x0\n"
    ret+="FORMAT \"%3.1\""
    ret+="/begin IF_DATA CANAPE_EXT\n"
    ret+="100\n"
    ret+="LINK_MAP \"storage_ine_dcu_ad._ad_output._"+self.name+"\" 0x00000000 0x0 0 0x0 1 0x87 0x0\n"
    ret+="DISPLAY 0 0 1\n"
    ret+="/end IF_DATA\n"
    ret+="SYMBOL_LINK \"storage_ine_dcu_ad._ad_output._"+self.name+"\" 0\n"
    ret+="/end MEASUREMENT\n\n"
    ret+="/begin MEASUREMENT "+self.name+"_counter \"\"\n"
    ret+="UBYTE NO_COMPU_METHOD 0 0 0 255\n"
    ret+="BYTE_ORDER MSB_FIRST\n"
    ret+="ECU_ADDRESS 0x00000000\n"
    ret+="ECU_ADDRESS_EXTENSION 0x0\n"
    ret+="FORMAT \"%.15\"\n"
    ret+="/begin IF_DATA CANAPE_EXT\n"
    ret+="100\n"
    ret+="LINK_MAP \"storage_ine_dcu_ad._ad_output._"+self.name+"\" 0x00000000 0x0 0 0x0 1 0x87 0x0\n"
    ret+="DISPLAY 0 0 255\n"
    ret+="/end IF_DATA\n"
    ret+="SYMBOL_LINK \"storage_ine_dcu_ad._ad_output._"+self.name+"_counter\" 0\n"
    ret+="/end MEASUREMENT\n\n"
=end

    ret="/begin MEASUREMENT "+self.name+" \"\"\n"
    ret+="UBYTE Boolean 0 0 0 1\n"
      ret+="BYTE_ORDER MSB_FIRST\n"
      ret+="ECU_ADDRESS 0x00000000\n"
      ret+="ECU_ADDRESS_EXTENSION 0x0\n"
      ret+="FORMAT \"%3.1\"\n"
      ret+="/begin IF_DATA CANAPE_EXT\n"
        ret+="100\n"
        ret+="LINK_MAP \"storage_ine_dcu_ad._ad_output._"+self.name+".req\" 0x00000000 0x0 0 0x0 1 0x87 0x0\n"
        ret+="DISPLAY 0 0 1\n"
      ret+="/end IF_DATA\n"
      ret+="SYMBOL_LINK \"storage_ine_dcu_ad._ad_output._"+self.name+".req\" 0\n"
    ret+="/end MEASUREMENT\n\n"

    ret+="/begin MEASUREMENT "+self.name+"_current_timer \"\"\n"
      ret+="ULONG NO_COMPU_METHOD 0 0 0 4000000\n"
      ret+="BYTE_ORDER MSB_FIRST\n"
      ret+="ECU_ADDRESS 0x00000000\n"
      ret+="ECU_ADDRESS_EXTENSION 0x0\n"
      ret+="FORMAT \"%.15\"\n"
      ret+="/begin IF_DATA CANAPE_EXT\n"
        ret+="100\n"
        ret+="LINK_MAP \"storage_ine_dcu_ad._ad_output._"+self.name+".current_timer\" 0x00000000 0x0 0 0x0 1 0x9F 0x0\n"
        ret+="DISPLAY 0 0 4000000\n"
      ret+="/end IF_DATA\n"
      ret+="SYMBOL_LINK \"storage_ine_dcu_ad._ad_output._"+self.name+".current_timer\" 0\n"
    ret+="/end MEASUREMENT\n\n"

    ret+="/begin MEASUREMENT "+self.name+"_timed_counter \"\"\n"
      ret+="UBYTE NO_COMPU_METHOD 0 0 0 255\n"
      ret+="BYTE_ORDER MSB_FIRST\n"
      ret+="ECU_ADDRESS 0x00000000\n"
      ret+="ECU_ADDRESS_EXTENSION 0x0\n"
      ret+="FORMAT \"%.15\"\n"
      ret+="/begin IF_DATA CANAPE_EXT\n"
      ret+="100\n"
        ret+="LINK_MAP \"storage_ine_dcu_ad._ad_output._"+self.name+".timed_counter\" 0x00000000 0x0 0 0x0 1 0x87 0x0\n"
        ret+="DISPLAY 0 0 255\n"
      ret+="/end IF_DATA\n"
      ret+="SYMBOL_LINK \"storage_ine_dcu_ad._ad_output._"+self.name+".timed_counter\" 0\n"
    ret+="/end MEASUREMENT\n\n"

    ret+="/begin MEASUREMENT "+self.name+"_untimed_counter \"\"\n"
      ret+="UBYTE NO_COMPU_METHOD 0 0 0 255\n"
      ret+="BYTE_ORDER MSB_FIRST\n"
      ret+="ECU_ADDRESS 0x00000000\n"
      ret+="ECU_ADDRESS_EXTENSION 0x0\n"
      ret+="FORMAT \"%.15\"\n"
      ret+="/begin IF_DATA CANAPE_EXT\n"
        ret+="100\n"
        ret+="LINK_MAP \"storage_ine_dcu_ad._ad_output._"+self.name+".untimed_counter\" 0x00000000 0x0 0 0x0 1 0x87 0x0\n"
        ret+="DISPLAY 0 0 255\n"
      ret+="/end IF_DATA\n"
      ret+="SYMBOL_LINK \"storage_ine_dcu_ad._ad_output._"+self.name+".untimed_counter\" 0\n"
    ret+="/end MEASUREMENT\n\n"

  end
  
  
  # --- Permissions --- #

  def create_permitted?
    if (project) then
      project.updatable_by?(acting_user)
    else
      false
    end
  end

  def update_permitted?
    project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    project.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    ret=self.project.viewable_by?(acting_user)
    if (!(acting_user.developer? || acting_user.administrator?)) then
      ret=self.project.public || self.layer_visible_by?(acting_user)
    end
    return ret
  end

end

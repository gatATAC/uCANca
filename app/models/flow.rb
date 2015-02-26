class Flow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    alternate_name :string
    puntero :boolean, :default => false
    timestamps
  end
  attr_accessible :name, :flow_type_id, :flow_type, :project, :project_id, :primary_flow_direction, :primary_flow_direction_id

  belongs_to :project, :inverse_of => :flows
  belongs_to :flow_type
  belongs_to :primary_flow_direction, :class_name => 'FlowDirection'

  belongs_to :datum_conversion  
  
  has_many :sub_system_flows, :dependent => :destroy
  has_many :connectors, :through => :sub_system_flows

  has_many :faults, :inverse_of => :flow
  has_many :data, :inverse_of => :flow, :dependent => :destroy
  
  children :sub_system_flows, :data

  validates :name, :presence => true
  validates :flow_type, :presence => true
  validates :project, :presence => true
  

  def current_pattern
      if (self.project.target)
        tgt=self.project.target.flow_type_targets
        ft=tgt.find_by_flow_type_id(self.flow_type_id);
        if (ft)
          return ft
        end
      end
      return self.flow_type
  end
  
  def to_define
    if (self.current_pattern) then
      return self.current_pattern.to_define(self)
    else
      return "// (null) "+self.name
    end
  end

  def c_name
    ret=""
    primchar=self.name.chars.first
    if (primchar>='0' && primchar<='9') then
      ret="_"
    end
    ret+=self.name.gsub("+", "_POS")
    ret=ret.gsub("-", "_NEG")
    ret=ret.gsub("/", "NEG_")
  end

  def to_c_decl
    if (self.current_pattern) then
      ret=self.current_pattern.to_c_type(self).+" "+self.c_name+";\n"
      return ret
    else
      return "// (null) "+self.name+"\n"
    end
  end

  def to_diag_c_decl
    ret=""
    if (self.current_pattern) then
      if (!self.current_pattern.phantom_type) then
        ret="BOOL enable_"+self.c_name+";\n"
        ret+=self.current_pattern.to_c_type(self).+" "+self.c_name+";\n"
      else
             return "// (null) No diag variables for "+self.c_name+"\n"
      end
    else
      return "// (null) No diag variables for "+self.c_name+"\n"
    end
  end

  def to_c_io_decl
    if (self.current_pattern) then
      ret="\n// "+self.c_name+" flow acquisition\n"
      ret+=current_pattern.to_c_input_decl(self)
      ret+="\n// "+self.c_name+" flow synthesis\n"
      ret+=current_pattern.to_c_output_decl(self)
    else
      ret="// (null)"
      ret+=" "+self.c_name+";\n"
    end
  end

  def to_c_io_setup_decl
    if (self.current_pattern) then
      ret="\n// "+self.c_name+" flow acquisition\n"
      ret+=current_pattern.to_c_setup_input_decl(self)
      ret+="\n// "+self.c_name+" flow synthesis\n"
      ret+=current_pattern.to_c_setup_output_decl(self)
    else
      ret="// (null)"
      ret+=" "+self.c_name+";\n"
    end
  end

  def to_c_io_setup
    if (self.current_pattern) then
      ret="\n// "+self.c_name+" flow acquisition\n"
      ret+=current_pattern.to_c_setup_input(self)
      ret+="\n// "+self.c_name+" flow synthesis\n"
      ret+=current_pattern.to_c_setup_output(self)
    else
      ret="// (null)"
      ret+=" "+self.c_name+";\n"
    end

  end
  
  def to_c_io
    if (self.current_pattern) then
      ret="\n// "+self.c_name+" flow acquisition\n"
      ret+=current_pattern.to_c_input(self)
      ret+="\n// "+self.c_name+" flow synthesis\n"
      ret+=current_pattern.to_c_output(self)
    else
      ret="// (null)"
      ret+=" "+self.c_name+";\n"
    end
  end

  def to_c_preview
    ret="// Types declaration\n"
    ret+=to_c_decl
    ret+="...\n\n// Diags declaration\n"
    ret+=to_diag_c_decl
    ret+="...\n\n// IO Declaration"
    ret+=to_c_io_decl
    ret+="\n...\n\n// IO Setup"
    ret+=to_c_io_setup
    ret+="\n...\n\n// IO Functions"
    ret+=to_c_io
    return ret
  end

  def self.import_attributes
    ret=Flow.accessible_attributes.clone
    ret.delete("project_id")
    ret.delete("project")
    ret.delete("flow_type")
    ret.delete("")
    return ret
  end
  
  # --- Permissions --- #


  def create_permitted?
    project.updatable_by?(acting_user)
  end

  def update_permitted?
    project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    project.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    project.viewable_by?(acting_user)
  end

end

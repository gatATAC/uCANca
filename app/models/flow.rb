class Flow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    alternate_name :string
    puntero :boolean, :default => false
    timestamps
  end
  attr_accessible :name, :flow_type_id, :flow_type, :project, :project_id

  belongs_to :project, :inverse_of => :flows
  belongs_to :flow_type

  has_many :sub_system_flows, :dependent => :destroy
  has_many :connectors, :through => :sub_system_flows

  children :sub_system_flows

  validates :name, :presence => true
  validates :flow_type, :presence => true
  validates :project, :presence => true

  def to_define
    if (self.flow_type) then
      return self.flow_type.to_define(self)
    else
      return "// (null) "+self.name
    end
  end

  def c_name
    ret=self.name.gsub("+", "_pos")
    ret=ret.gsub("-", "_neg")
  end

  def to_c_decl
    if (self.flow_type) then
      ret="\t"
      ret+=self.flow_type.to_c_type(self).+" "+self.c_name+";\n"
      return ret
    else
      return "// (null) "+self.name+"\n"
    end
  end

  def to_diag_c_decl
    ret=""
    if (self.flow_type) then
      if (!self.flow_type.phantom_type) then
        ret="\tBOOL enable_"+self.c_name+";\n\t"
        ret+=self.flow_type.to_c_type(self).+" "+self.c_name+";\n"
      end
    else
      return "// (null) "+self.c_name+"\n"
    end
  end

  def to_c_io_decl
    if (self.flow_type) then
      ret="\n\n// "+self.c_name+" flow acquisition\n"
      ret+=flow_type.to_c_input_decl(self)
      ret+="\n// "+self.c_name+" flow synthesis\n"
      ret+=flow_type.to_c_output_decl(self)
    else
      ret="// (null)"
      ret+=" "+self.c_name+";\n"
    end
  end

  def to_c_io
    if (self.flow_type) then
      ret="\n// "+self.c_name+" flow acquisition\n"
      ret+=flow_type.to_c_input(self)
      ret+="\n\n// "+self.c_name+" flow synthesis\n"
      ret+=flow_type.to_c_output(self)
    else
      ret="// (null)"
      ret+=" "+self.c_name+";\n"
    end
  end

  def to_c
    ret=to_c_decl
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

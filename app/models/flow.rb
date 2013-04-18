class Flow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    timestamps
  end
  attr_accessible :name, :flow_type_id, :flow_type, :project, :project_id

  belongs_to :project, :inverse_of => :flows
  belongs_to :flow_type

  has_many :sub_system_flows
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

  def to_c_decl
    if (self.flow_type) then
      ret="\t"
      ret+=self.flow_type.to_c_type(self).+" "+self.name+";\n"
      return ret
    else
      return "// (null) "+self.name+"\n"
    end
  end

  def to_diag_c_decl
    ret=""
    if (self.flow_type) then
      if (!self.flow_type.tipo_fantasma) then
        ret="\tBOOL enable_"+self.name+";\n\t"
        ret+=self.flow_type.to_c_type(self).+" "+self.name+";\n"
      end
    else
      return "// (null) "+self.name+"\n"
    end
  end

  def to_c_io_decl
    if (self.flow_type) then
      ret="\n\n// Adquisicion de la variable "+self.name+"\n"
      ret+=flow_type.to_c_input_decl(self)
      ret+="\n// Sintesis de la variable "+self.name+"\n"
      ret+=flow_type.to_c_output_decl(self)
    else
      ret="// (null)"
      ret+=" "+self.name+";\n"
    end
  end

  def to_c_io
    if (self.flow_type) then
      ret="\n// Adquisicion de la variable "+self.name+"\n"
      ret+=flow_type.to_c_input(self)
      ret+="\n\n// Sintesis de la variable "+self.name+"\n"
      ret+=flow_type.to_c_output(self)
    else
      ret="// (null)"
      ret+=" "+self.name+";\n"
    end
  end

  def to_c
    ret=to_c_decl
    ret+=to_c_io
    return ret
  end

  def parent_project
    project
  end

  # --- Permissions --- #


  def create_permitted?
    parent_project.updatable_by?(acting_user)
  end

  def update_permitted?
    parent_project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    parent_project.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end

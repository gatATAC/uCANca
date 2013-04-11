class Flow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    timestamps
  end
  attr_accessible :name, :flow_type_id, :flow_type

  belongs_to :flow_type

  has_many :sub_system_flows
  has_many :connectors, :through => :sub_system_flows

  children :sub_system_flows

  validates :name, :presence => true
  validates :flow_type, :presence => true

  def self.to_h
    ret="#ifndef _DRE_H\n#define _DRE_H\n\n"
    ret+=self.to_c_decl
    ret+=self.to_c_io_decl
    ret+="\n#endif /* _DRE_H */\n"
  end

  def self.to_c
    ret="#include \"DRE.h\"\n\n"
    ret+="// --- Declaracion de la estructura de datos del DRE ---\nt_dre dre;\n"
    ret+="\n\n// --- Funciones de adquisicion y sintesis del DRE ---\n\n"
    ret+=self.to_c_io
  end

  def self.to_c_decl
    ret="typedef struct {\n"
    self.find(:all).each{ |f|
      ret+="\t"+f.to_c_decl+"\n"
    }
    ret+="} t_dre;\n\n"
  end

  def self.to_c_io
    ret="// Funciones de entrada y salida\n"
    ret=""
    self.find(:all).each{ |f|
      ret+=f.to_c_io;
    }
    ret+="\n\n"
  end

  def self.to_c_io_decl
    ret="// Funciones de entrada y salida\n"
    ret=""
    self.find(:all).each{ |f|
      ret+=f.to_c_io_decl;
    }
    ret+="\n\n"
  end

  def to_c_decl
    #ret="// Declaracion de la variable\n"
    ret=""
    if (self.flow_type) then
      ret+=self.flow_type.to_c_type(self)+" "+self.name+";"
    else
      ret+="// (null) "+self.name
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
      ret="\n\n// Adquisicion de la variable "+self.name+"\n"
      ret+=flow_type.to_c_input(self)
      ret+="\n// Sintesis de la variable "+self.name+"\n"
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

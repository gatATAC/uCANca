class FaultRequirement < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string, :required, :unique
    abbrev :string, :required, :unique
    abbrev_c :string, :required, :unique
    timestamps
  end
  
  attr_accessible :name, :abbrev, :abbrev_c, :project, :project_id

  has_many :faults, :dependent => :destroy
  belongs_to :project,  :creator => true
  
  children :faults
  
  validates :project, :presence => :true
  

  ################ Code generation


  def to_structure
    ret="\n\n/***"
    ret+=self.name
    ret+="***/"
    self.faults.each { |f|
      ret+=f.to_structure
    }
    return ret
  end

  def to_structure_define
    ret="\n/***"
    ret+=self.name
    ret+="***/\n"
    self.faults.each { |f|
      ret+=f.to_structure_define
    }
    return ret
  end

  def to_autodiag_main
    ret="\n/***"
    ret+=self.name
    ret+="***/\n"
    self.faults.each { |f|
      ret+=f.to_autodiag_main
    }

    return ret
  end

  def to_autodiag_main_c
    ret="\n/***"
    ret+=self.name
    ret+="***/\n\n"
    self.faults.each { |f|
      ret+=f.to_autodiag_main_c
    }
    return ret
  end

  def to_autodiag_main_functions_c
    ret="\n/***"
    ret+=self.name
    ret+="***/\n\n"
    self.faults.each { |f|
      ret+=f.to_autodiag_main_functions_c
    }
    return ret
  end

  def to_autodiag_main_functions
    ret="\n/***"
    ret+=self.name
    ret+="***/\n\n"
    self.faults.each { |f|
      ret+=f.to_autodiag_main_functions
    }
    return ret
  end

  def to_diagmux
    ret="\n/***"
    ret+=self.name
    ret+="***/\n"
    self.faults.each { |f|
      ret+=f.to_diagmux
    }
    return ret
  end

  def to_diagmux_c
    ret="\n/***"
    ret+=self.name
    ret+="***/\n\n"
    self.faults.each { |f|
      ret+=f.to_diagmux_c
    }
    return ret
  end

  def to_diagmux_call_init
    ret="\n\t/***"
    ret+=self.name
    ret+="***/\n\n"
    self.faults.each { |f|
      ret+=f.to_diagmux_call_init
    }
    return ret
  end
  def to_diagmux_call_normal
    ret="\n\t/***"
    ret+=self.name
    ret+="***/\n\n"
    self.faults.each { |f|
      ret+=f.to_diagmux_call_normal
    }
    return ret
  end
  def to_diagmux_call_mux
    ret="\n\t/***"
    ret+=self.name
    ret+="***/\n\n"
    self.faults.each { |f|
      ret+=f.to_diagmux_call_mux
    }
    return ret
  end

  def to_sendmessage
    ret="\n\t/***"
    ret+=self.name
    ret+="***/\n\n"
    self.faults.each { |f|
      ret+=f.to_sendmessage
    }
    return ret
  end
  
  
  def self.import_attributes
    ret=self.accessible_attributes.clone
    ret.delete("project_id")
    ret.delete("project")
    #ret.delete("flow_type")
    ret.delete("")
    return ret
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

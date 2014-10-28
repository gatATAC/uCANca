class FunctionSubSystem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    implementacion :boolean, :default => false
    timestamps
  end
  
  attr_accessible :sub_system, :sub_system_id, :function, :function_id, :implementacion, :name

  belongs_to :sub_system, :inverse_of => :function_sub_systems
  belongs_to :function, :inverse_of => :function_sub_systems

  validates :sub_system, :presence => :true
  validates :function, :presence => :true

  has_many :state_machines, :inverse_of => :function_sub_system, :dependent => :destroy
  has_many :state_machine_conditions, :inverse_of => :function_sub_system, :dependent => :destroy
  has_many :state_machine_actions, :inverse_of => :function_sub_system, :dependent => :destroy

  children :state_machines, :state_machine_conditions, :state_machine_actions
  
  acts_as_list :scope => :sub_system

  before_save :remove_project_temp
  
  attr_accessor :project_temp # atributo temporal para conseguir añadir nuevas instancias desde cualquiera de sus dos "padres": subsistema o funcion

  def project
    if project_temp then
      ret=project_temp
    else
      if sub_system then
        ret=sub_system.project
      else
        if function then
          ret=function.project
        end
      end
    end
    return ret
  end

  def remove_project_temp
    self.project_temp = nil
  end

  def to_func_name
    (sub_system.full_abbrev.capitalize+"_"+function.abbrev).camelize
  end

  # --- Permissions --- #

  def create_permitted?
    project.updatable_by?(acting_user)
  end

  def update_permitted?
    project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    project.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    project.viewable_by?(acting_user)
  end

end

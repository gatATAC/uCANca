class FaultFailSafeCommand < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    feedback_required :boolean, :default => true
    timestamps
  end
  attr_accessible :feedback_required,:fault, :fault_id, :fail_safe_command_id, :fail_safe_command, :fail_safe_command_time, :fail_safe_command_time_id
  
  belongs_to :fail_safe_command, :creator => true, :inverse_of => :fault_fail_safe_commands
  belongs_to :fault, :creator => true, :inverse_of => :fault_fail_safe_commands
  belongs_to :fail_safe_command_time, :inverse_of => :fault_fail_safe_commands

  before_save :remove_project_temp
  
  attr_accessor :project_temp # atributo temporal para conseguir añadir nuevas instancias desde cualquiera de sus dos "padres": subsistema o funcion
  
  def project
    if project_temp then
      ret=project_temp
    else
        if fail_safe_command then
          ret=fail_safe_command.project
      else
        if fault then
          ret=fault.project
        end
      end
    end
    return ret
  end
  

  def remove_project_temp
    self.project_temp = nil
  end
  
  # --- Permissions --- #

=begin
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
=end

  def create_permitted?
    true
  end

  def update_permitted?
    true
  end

  def destroy_permitted?
    true
  end

  def view_permitted?(field)
    true
  end
  
end

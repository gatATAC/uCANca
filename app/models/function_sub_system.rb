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

  has_many :state_machines, :inverse_of => :function_sub_system

  children :state_machines
  
  acts_as_list :scope => :sub_system
  
  def parent_project
    function.parent_project
  end

  def to_func_name
    (sub_system.full_abbrev.capitalize+"_"+function.abbrev).camelize
  end

  # --- Permissions --- #

  def create_permitted?
    if (sub_system) then
      return sub_system.updatable_by?(acting_user)
    else
      if (function) then
        return function.updatable_by?(acting_user)
      else
        true
      end
    end
  end

  def update_permitted?
    if (sub_system) then
      return sub_system.updatable_by?(acting_user)
    else
      if (function) then
        return function.updatable_by?(acting_user)
      end
    end
  end

  def destroy_permitted?
    if (sub_system) then
      return sub_system.updatable_by?(acting_user)
    else
      if (function) then
        return function.updatable_by?(acting_user)
      end
    end
  end

  def view_permitted?(field)
      if (function) then
        function.viewable_by?(acting_user)
      else
        if (sub_system) then
          sub_system.viewable_by?(acting_user)
        else
          true
        end
      end
    end

end

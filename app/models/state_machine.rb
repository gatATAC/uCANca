class StateMachine < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end
  attr_accessible :name, :function_sub_system, :function_sub_system_id


  belongs_to :function_sub_system

  has_many :state_machine_states, :inverse_of => :state_machine
  belongs_to :super_state, :class_name => 'StateMachineState', :inverse_of => :sub_machines, :foreign_key => :super_state_id
  has_many :sub_machines, :through => :state_machine_states, :class_name => 'StateMachine', :foreign_key => :super_state_id

  children :state_machine_states, :sub_machines

  def to_func_name
    ret=function_sub_system.to_func_name+"_"+name.to_s
    return ret
  end

  # --- Permissions --- #

  def create_permitted?
    if (function_sub_system) then
      return function_sub_system.updatable_by?(acting_user)
    else
      true
    end
  end

  def update_permitted?
    if (function_sub_system) then
      return function_sub_system.updatable_by?(acting_user)
    else
      true
    end
  end

  def destroy_permitted?
    if (function_sub_system) then
      return function_sub_system.updatable_by?(acting_user)
    else
      true
    end
  end

  def view_permitted?(field)
    if (function_sub_system) then
      function_sub_system.viewable_by?(acting_user)
    else
      true
    end
  end

end

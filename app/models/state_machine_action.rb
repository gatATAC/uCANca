class StateMachineAction < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name           :string
    short_name        :string
    description    :text
    implementation :text
    timestamps
  end
  attr_accessible :name, :description, :implementation, :function_sub_system, :function_sub_system_id, :short_name

  belongs_to :function_sub_system, :inverse_of => :state_machine_actions
  has_many :transition_actions,:class_name => 'StateMachineTransitionAction', :foreign_key => 'action_id' ,:inverse_of => :action
  has_many :transitions, :class_name => 'StateMachineTransition', :through => :transition_actions, :dependent => :destroy

  validates :implementation, :presence => :true
  validates :name, :presence => :true
  validates :function_sub_system, :presence => :true

  def diagram_name
    if self.short_name then
      ret=self.short_name
    else
      ret=self.name
    end
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
    function_sub_system.updatable_by?(acting_user)
  end

  def destroy_permitted?
    function_sub_system.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    ret=false
    if function_sub_system then
      ret=function_sub_system.viewable_by?(acting_user)
    end
    return ret
  end

end

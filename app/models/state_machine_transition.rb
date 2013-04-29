class StateMachineTransition < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    priority    :integer
    timestamps
  end
  attr_accessible :name, :description, :priority, :destination_state, :destination_state_id, :state_machine_condition_id, :state_machine_condition, :transition_actions, :actions

  belongs_to :state_machine_state, :inverse_of => :state_machine_transitions
  belongs_to :destination_state, :class_name => 'StateMachineState', :inverse_of => :incoming_transitions
  belongs_to :state_machine_condition, :inverse_of => :state_machine_transitions
  has_many :transition_actions, :class_name => 'StateMachineTransitionAction', :foreign_key => 'transition_id', :inverse_of => :transition, :accessible => :true
  has_many :actions, :class_name => 'StateMachineAction', :through => :transition_actions, :dependent => :destroy, :accessible => :true

  validates :state_machine_state, :presence => :true


  children :actions

  def diagram_name
    if (name) then
      return name
    else
      return "No name"
    end
  end

  def diagram_description
    if (description) then
      return description
    else
      return "No description"
    end
  end

  def condition_name
    if state_machine_condition then
      state_machine_condition.diagram_name
    else
      ""
    end
  end

  def action_short_names
    ret=[]
    self.actions.each {|a|
      ret << a.diagram_name
    }
    return ret
  end

  # --- Permissions --- #

  def create_permitted?
    if state_machine_state then
      state_machine_state.updatable_by?(acting_user)
    else
      true
    end
  end

  def update_permitted?
    state_machine_state.updatable_by?(acting_user)
  end

  def destroy_permitted?
    state_machine_state.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    state_machine_state.viewable_by?(acting_user)
  end


end

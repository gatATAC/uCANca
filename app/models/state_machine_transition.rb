class StateMachineTransition < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    priority    :integer
    timestamps
  end
  attr_accessible :name, :description, :priority, :destination_state, :destination_state_id, :state_machine_condition_id, :state_machine_condition, :state_machine_transition_actions

  belongs_to :state_machine_state, :inverse_of => :state_machine_transitions
  belongs_to :destination_state, :class_name => 'StateMachineState', :inverse_of => :incoming_transitions
  belongs_to :state_machine_condition, :inverse_of => :state_machine_transitions
  has_many :state_machine_transition_actions, :inverse_of => :state_machine_transition, :accessible => :true

  validates :state_machine_state, :presence => :true

  has_many :state_machine_actions, :through => :state_machine_transition_actions, :dependent => :destroy

  children :state_machine_transition_actions

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

  def state_machine_action_short_names
    ret=[]
    self.state_machine_actions.each {|a|
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

class StateMachineTransitionAction < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  attr_accessible :state_machine_transition, :state_machine_transition_id, :state_machine_action, :state_machine_action_id

  belongs_to :state_machine_transition, :inverse_of => :state_machine_transition_actions, :creator => :true
  belongs_to :state_machine_action, :inverse_of => :state_machine_transition_actions

  # --- Permissions --- #

  def create_permitted?
    state_machine_transition.updatable_by?(acting_user)
  end

  def update_permitted?
    state_machine_transition.updatable_by?(acting_user)
  end

  def destroy_permitted?
    state_machine_transition.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    if state_machine_transition then
      state_machine_transition.viewable_by?(acting_user)
    else
      true
    end
  end

end

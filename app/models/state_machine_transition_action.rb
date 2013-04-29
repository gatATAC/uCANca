class StateMachineTransitionAction < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  attr_accessible :transition, :transition_id, :action, :action_id

  belongs_to :transition, :class_name => 'StateMachineTransition', :inverse_of => :transition_actions, :creator => :true
  belongs_to :action, :class_name => 'StateMachineAction', :inverse_of => :transition_actions

  validates :transition, :presence => :true
  validates :action, :presence => :true

  def name
    action.name
  end

  # --- Permissions --- #

  def create_permitted?
    transition.updatable_by?(acting_user)
  end

  def update_permitted?
    transition.updatable_by?(acting_user)
  end

  def destroy_permitted?
    transition.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    transition.viewable_by?(acting_user)
  end

end

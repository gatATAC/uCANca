class StateMachineTransition < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    priority    :integer
    timestamps
  end
  attr_accessible :name, :description, :priority, :destination_state, :destination_state_id, :state_machine_condition_id, :state_machine_condition

  belongs_to :state_machine_state, :inverse_of => :state_machine_transitions
  belongs_to :destination_state, :class_name => 'StateMachineState', :inverse_of => :incoming_transitions
  belongs_to :state_machine_condition, :inverse_of => :state_machine_transitions

  validates :state_machine_state, :presence => :true

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



  # --- Permissions --- #

  def create_permitted?
    state_machine_state.updatable_by?(acting_user)
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

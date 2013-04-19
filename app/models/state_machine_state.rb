class StateMachineState < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    initial     :boolean
    final       :boolean
    timestamps
  end
  attr_accessible :name, :description, :state_machine, :state_machine_id, :initial, :final, :sub_machines

  belongs_to :state_machine, :inverse_of => :state_machine_states
  has_many :sub_machines, :class_name => 'StateMachine', :limit => 1, :inverse_of => :super_state, :foreign_key => :super_state_id
  has_many :state_machine_transitions, :inverse_of => :state_machine_state
  has_many :incoming_transitions, :inverse_of => :destination_state

  children :state_machine_transitions,:sub_machines

  validates :state_machine, :presence => :true
  # --- Permissions --- #

  def create_permitted?
    state_machine.updatable_by?(acting_user)
  end

  def update_permitted?
    state_machine.updatable_by?(acting_user)
  end

  def destroy_permitted?
    state_machine.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    state_machine.viewable_by?(acting_user)
  end

end

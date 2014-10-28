class StateMachineCondition < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name              :string
    short_name        :string
    description       :text
    implementation    :text
    timestamps
  end
  attr_accessible :name, :description, :implementation, :short_name

  belongs_to :function_sub_system, :inverse_of => :state_machine_conditions, :creator => :true
  has_many :state_machine_transitions, :inverse_of => :state_machine_condition

  validates :implementation, :presence => :true
  validates :name, :presence => :true
  validates :function_sub_system, :presence => :true

  def diagram_name
    if short_name then
      return short_name
    else
      return name
    end
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
      function_sub_system.viewable_by?(acting_user)
  end

end

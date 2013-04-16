class FunctionSubSystem < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  attr_accessible :sub_system, :function, :sub_system_id, :function_id

  belongs_to :sub_system
  belongs_to :function

  validates :sub_system, :presence => :true
  validates :function, :presence => :true

  def name
    ret=""
    if (sub_system) then
      ret+="["+sub_system.name+"]"
    end
    if (function) then
      ret+=function.name
    end
    
  end

  def parent_project
    function.parent_project
  end

  # --- Permissions --- #

  def create_permitted?
    sub_system.updatable_by?(acting_user)
  end

  def update_permitted?
    sub_system.updatable_by?(acting_user)
  end

  def destroy_permitted?
    sub_system.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    sub_system.viewable_by? (acting_user)
  end


end

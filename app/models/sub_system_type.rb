class SubSystemType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    name :abbrev
    timestamps
  end
  attr_accessible :name,:abbrev
  
  has_many :sub_systems, :inverse_of => :sub_system_type

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end

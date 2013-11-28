class FlowDirection < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    img         :string
    timestamps
  end
  attr_accessible :name, :description, :img

  has_many :sub_system_flows, :inverse_of => :flow_direction

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

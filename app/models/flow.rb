class Flow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    timestamps
  end
  attr_accessible :name, :flow_type_id, :flow_type

  belongs_to :flow_type

  has_many :sub_system_flows
  has_many :connectors, :through => :sub_system_flows

  children :sub_system_flows

  validates :name, :presence => true
  validates :flow_type, :presence => true
  
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

class Flow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    outdir :boolean
    timestamps
  end
  attr_accessible :name, :outdir, :flow_type_id, :flow_type

  belongs_to :flow_type

  has_many :sub_system_flows
  has_many :sub_systems, :through => :sub_system_flows

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

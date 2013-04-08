class SubSystemFlow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  attr_accessible :flow, :connector, :connector_id, :flow_id, :position

  belongs_to :flow
  belongs_to :connector

  validates :flow, :presence => true
  validates :connector, :presence => true

  acts_as_list :scope => :connector

  def name
    ret=connector.sub_system.name+"_"+flow.name
  end

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

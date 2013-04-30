class SubSystemFlow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    outdir :boolean
    timestamps
  end
  attr_accessible :flow, :connector, :connector_id, :flow_id, :position, :outdir

  belongs_to :flow, :inverse_of => :sub_system_flows, :creator => :true
  belongs_to :connector, :inverse_of => :sub_system_flows, :creator => :true

  validates :flow, :presence => :true
  validates :connector, :presence => :true

  acts_as_list :scope => :connector

  def name
    ret=connector.sub_system.full_name+"_"+flow.name
  end

  def project
    flow.project
  end

  # --- Permissions --- #

  def create_permitted?
    connector.updatable_by?(acting_user)
  end

  def update_permitted?
    connector.updatable_by?(acting_user)
  end

  def destroy_permitted?
    connector.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    connector.viewable_by? (acting_user)
  end

end

class ConfigurationSwitch < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    ident :string
    timestamps
  end
  attr_accessible :name, :ident, :project, :project_id
  
  belongs_to :project, :creator => :true, :inverse_of => :configuration_switches

  has_many :uds_services, :inverse_of => :configuration_switch
  has_many :uds_sub_services, :inverse_of => :configuration_switch
  has_many :uds_service_identifiers, :inverse_of => :configuration_switch
  has_many :uds_service_fixed_params, :inverse_of => :configuration_switch

  validates :project, :presence => :true
  
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

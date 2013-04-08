class Connector < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end

  attr_accessible :name, :sub_system_flows

  belongs_to :sub_system
  has_many :sub_system_flows, :order => :position

  acts_as_list :scope => :sub_system

  children :sub_system_flows

  validates :sub_system, :presence => true
  def full_name
    sub_system.name+"_"+name
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

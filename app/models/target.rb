class Target < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string
    description :text
    timestamps
  end
  attr_accessible :name, :description

  has_many :projects
  has_many :sub_systems
  has_many :flow_type_targets, :dependent => :destroy
  
  children :flow_type_targets
  
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

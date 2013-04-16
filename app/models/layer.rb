class Layer < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name  :string
    level :integer
    timestamps
  end
  attr_accessible :name, :level

  validates :name, :presence => :true
  validates :level, :presence => :true
  
  has_many :sub_systems
  
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

class UdsServiceManager < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident       :string
    name        :string
    description :text
    timestamps
  end
  attr_accessible :ident, :name, :description

  belongs_to :project, :creator => :true, :inverse_of => :uds_service_managers
  
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

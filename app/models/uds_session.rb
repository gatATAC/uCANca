class UdsSession < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident    :string
    name     :string
    sub_name :string
    timestamps
  end
  attr_accessible :ident, :name, :sub_name, :project, :project_id
  
  belongs_to :project, :creator => :true, :inverse_of => :uds_sessions

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

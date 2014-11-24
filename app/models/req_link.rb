class ReqLink < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    
    is_external :boolean
    ext_url :string
    timestamps
  end
  
  attr_accessible :requirement, :requirement_id

  belongs_to :requirement, :creator=>:true, :inverse_of => :req_links
  belongs_to :req_source, :class_name => 'Requirement', :inverse_of => :incoming_links
  
  validates :requirement, :presence => :true
  validates :req_source, :presence => :true
  
  # --- Permissions --- #

  def create_permitted?
    if (requirement) then
      requirement.updatable_by?(acting_user)
    else
      false
    end
  end

  def update_permitted?
    requirement.updatable_by?(acting_user)
  end

  def destroy_permitted?
    requirement.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    ret=self.requirement.viewable_by?(acting_user)
    return ret
  end

end

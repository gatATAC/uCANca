class FaultPrecondition < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name              :string
    description       :text
    code              :text
    feedback_required :boolean, :default => true
    
    timestamps
  end
  attr_accessible :name, :description, :code, :feedback_required, :project, :project_id
  
  has_many :faults
  belongs_to :project, :creator => :true
  
  children :faults

  # --- Permissions --- #

  def create_permitted?
    if (project) then
      project.updatable_by?(acting_user)
    else
      false
    end
  end

  def update_permitted?
    project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    project.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    ret=self.project.viewable_by?(acting_user)
    if (!(acting_user.developer? || acting_user.administrator?)) then
      ret=self.project.public || self.layer_visible_by?(acting_user)
    end
    return ret
  end

end

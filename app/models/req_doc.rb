class ReqDoc < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name   :string
    timestamps
  end
  attr_accessible :name, :abbrev, :req_doc_type, :req_doc_type_id, :project_id

  belongs_to :project, :inverse_of => :req_docs, :creator => :true
  belongs_to :req_doc_type, :inverse_of => :req_docs
  
 
  validates :name, :presence => :true
  validates :project, :presence => :true
  validates :req_doc_type, :presence => :true

  has_many :requirements, :dependent => :destroy, :inverse_of => :req_doc, :order => :object_number

  children :requirements
  
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
      ret=self.project.public
    end
    return ret
  end

end

class Function < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident :string
    name :string
    description :text
    timestamps
  end
  attr_accessible :ident, :name, :description, :function_type, :function_type_id

  belongs_to :project
  belongs_to :function_type, :inverse_of => :functions

  has_many :function_sub_systems, :dependent => :destroy, :inverse_of => :function
  has_many :sub_systems, :through => :function_sub_systems

  validates :name, :presence => :true
  validates :ident, :presence => :true
  validates :project, :presence => :true
  validates :function_type, :presence => :true

  children :function_sub_systems

  def parent_project
    project
  end

  def abbrev
    ident.gsub(/\s+/, "_").camelize
  end

  # --- Permissions --- #


  def create_permitted?
    parent_project.updatable_by?(acting_user)
  end

  def update_permitted?
    parent_project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    parent_project.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    acting_user.signed_up?
  end

end

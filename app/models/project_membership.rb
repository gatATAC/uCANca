class ProjectMembership < ActiveRecord::Base


  hobo_model # Don't put anything above this

  fields do
    contributor :boolean, :default => false
    maximum_layer :integer, :default => 0
    timestamps
  end

  attr_accessible :contributor, :maximum_layer

  belongs_to :project, :inverse_of => :project_memberships
  belongs_to :user, :inverse_of => :project_memberships

  validates :project, :presence => :true
  validates :user, :presence => :true
  validates :maximum_layer, :presence => :true

  # --- Permissions --- #

  def create_permitted?
    project.updatable_by?(acting_user)
  end

  def update_permitted?
    project.updatable_by?(acting_user)
  end

  def destroy_permitted?
    project.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    project.viewable_by?(acting_user)
  end
end

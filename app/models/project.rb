class Project < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end
  attr_accessible :name

  belongs_to :owner, :class_name => "User", :creator => true, :inverse_of => :projects

  validates :name, :presence => :true
  validates :owner, :presence => :true


  has_many :project_memberships, :dependent => :destroy, :inverse_of => :project
  has_many :members, :through => :project_memberships, :source => :user
  has_many :sub_systems
  has_many :flows
  has_many :functions

  has_many :contributor_memberships, :class_name => "ProjectMembership", :conditions => {:contributor => true}
  has_many :contributors, :through => :contributor_memberships, :source => :user

  # permission helper
  def accepts_changes_from?(user)
    user.administrator? || user == owner || user.in?(contributors)
  end


  children :flows, :project_memberships, :sub_systems, :functions

  # --- Permissions --- #

  def create_permitted?
    (owner_is? acting_user)
  end

  def update_permitted?
    accepts_changes_from?(acting_user) && !owner_changed?
  end

  def destroy_permitted?
    (acting_user.administrator? || owner_is?(acting_user))
  end

  def view_permitted?(field)
    (acting_user.administrator? || acting_user == owner || acting_user.in?(members))
  end

end

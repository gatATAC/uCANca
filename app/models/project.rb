class Project < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    description :text
    public :boolean
    timestamps
  end
  
  attr_accessible :name, :owner, :owner_id, :public, :logo, :logo_file_name, :description, :target_id, :target

  has_attached_file :logo,
    :styles => {
    :medium => ["200x138#", :png],
    :thumb => ["100x100>", :png] },
    :whiny => false,
    :path => 'lib/logos/:style/:filename',
    :url => '/projects/:id?style=:style'  
  
  belongs_to :owner, :class_name => "User", :creator => true, :inverse_of => :projects
  belongs_to :target

  validates :name, :presence => :true
  validates :owner, :presence => :true

  has_many :project_memberships, :dependent => :destroy, :inverse_of => :project
  has_many :members, :through => :project_memberships, :source => :user
  has_many :sub_systems
  has_many :flows
  has_many :functions
  has_many :fault_requirements, :dependent => :destroy, :inverse_of => :project
  has_many :fail_safe_commands, :dependent => :destroy, :inverse_of => :project
  has_many :fail_safe_command_times, :dependent => :destroy, :inverse_of => :project
  has_many :fault_detection_moments, :dependent => :destroy, :inverse_of => :project
  has_many :fault_preconditions, :dependent => :destroy, :inverse_of => :project
  has_many :fault_recurrence_times, :dependent => :destroy, :inverse_of => :project
  has_many :fault_rehabilitations, :dependent => :destroy, :inverse_of => :project
  
  has_many :contributor_memberships, :class_name => "ProjectMembership", :conditions => {:contributor => true}
  has_many :contributors, :through => :contributor_memberships, :source => :user

  # permission helper
  def accepts_changes_from?(user)
    user.administrator? || user == owner || user.in?(contributors)
  end

  children :flows, :project_memberships, :sub_systems, :functions, :fault_requirements, :fail_safe_commands, :fail_safe_command_times, :fault_detection_moments, :fault_preconditions, :fault_recurrence_times, :fault_rehabilitations

  def to_iox
    return self.to_xml(:include =>{
        :sub_systems=>{:include => 
            {:connectors => {:include => 
                {:input_flows=>{:include => 
                    {:flow=>{:include => 
                        {:flow_type => {:only => 
                            [:name]
                        }
                      }
                    }
                  }
                }, 
                :output_flows=>{:include =>
                    {:flow=>{:include => 
                        {:flow_type => {:only => 
                            [:name]
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      })
  end
  
  def to_iocsv(options = {})
    CSV.generate(options) do |csv|
      csv << Flow.import_attributes
      self.flows.each do |flow|
        csv << flow.attributes.values_at(*Flow.import_attributes)
      end
    end
  end
  
  def root_sub_system
    sub_systems.each {|ss|
      if (ss.root)
        return ss.root
      end
    }
    return sub_systems.first
  end
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || ((owner_is? acting_user) && acting_user.developer)
  end

  def update_permitted?
    accepts_changes_from?(acting_user) && !owner_changed?
  end

  def destroy_permitted?
    (acting_user.administrator? || owner_is?(acting_user))
  end

  def view_permitted?(field)
    (acting_user.administrator? || acting_user == owner || acting_user.in?(members) || self.public)
  end

end

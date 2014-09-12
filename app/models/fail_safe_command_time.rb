class FailSafeCommandTime < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    ms   :integer
    feedback_required :boolean, :default => true
    timestamps
  end

  attr_accessible :name, :ms, :feedback_required, :project, :project_id

  has_many :fault_fail_safe_commands, :inverse_of => :fail_safe_command_time
  belongs_to :project, :creator => :true
  
  children :fault_fail_safe_commands
  
  def self.import_attributes
    ret=self.accessible_attributes.clone
    ret.delete("project_id")
    ret.delete("project")
    #ret.delete("flow_type")
    ret.delete("")
    return ret
  end

  
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

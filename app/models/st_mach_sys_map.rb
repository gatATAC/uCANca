class StMachSysMap < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    implementation :boolean
    timestamps
  end
  attr_accessible :implementation, :sub_system, :state_machine

  belongs_to :state_machine, :inverse_of => :st_mach_sys_maps, :creator => :true
  belongs_to :sub_system, :inverse_of => :st_mach_sys_maps, :creator => :true

  validates :state_machine, :presence => :true
  validates :sub_system, :presence => :true

  # --- Permissions --- #

  def create_permitted?
    state_machine.updatable_by?(acting_user)
  end

  def update_permitted?
    state_machine.updatable_by?(acting_user)
  end

  def destroy_permitted?
    state_machine.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    state_machine.viewable_by?(acting_user)
  end

end

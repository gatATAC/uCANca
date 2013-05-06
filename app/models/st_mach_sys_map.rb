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

  def name
    state_machine.name+" -> "+sub_system.full_name
  end

  # --- Permissions --- #

  def create_permitted?
    if (state_machine) then
      state_machine.updatable_by?(acting_user)
    else
      sub_system.updatable_by?(acting_user)
    end
  end

  def update_permitted?
    sub_system.updatable_by?(acting_user)
  end

  def destroy_permitted?
    sub_system.updatable_by?(acting_user)
  end

  def view_permitted?(field)
    if (sub_system) then
      sub_system.viewable_by?(acting_user)
    else
      state_machine.viewable_by?(acting_user)
    end
  end

end

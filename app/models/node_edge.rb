class NodeEdge < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  attr_accessible 

  belongs_to :source, :class_name => 'SubSystem', :creator => true
  belongs_to :destination, :class_name => 'SubSystem'

  acts_as_list :scope => :source


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

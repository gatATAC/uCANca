class EdiProcess < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident       :integer
    label       :string
    pos_x       :integer
    pos_y       :integer
    size_x      :integer
    size_y      :integer
    color       :integer
    master      :boolean
    description :text
    timestamps
  end
  attr_accessible :ident, :label, :pos_x, :pos_y, :size_x, :size_y, :color, :master, :description

  belongs_to :edi_model, :creator => :true, :inverse_of => :edi_processes
  belongs_to :sub_system
  
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

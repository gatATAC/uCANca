class EdiFlow < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident      :integer
    label      :string
    color      :integer
    pos_x      :integer
    pos_y      :integer
    data_type  :string
    prop       :string
    attr_name  :string
    attr_value :string
    attr_type  :string
    size_x     :integer
    size_y     :integer
    edi_type   :string
    internal   :boolean
    timestamps
  end
  attr_accessible :ident, :label, :color, :pos_x, :pos_y, :data_type, :prop, :attr_name, :attr_value, :attr_type, :size_x, :size_y, :edi_type, :internal

  belongs_to :edi_process, :creator =>:true, :inverse_of => :edi_flows
  
  def self.create_from_scratch(ssfl, conts)
  
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

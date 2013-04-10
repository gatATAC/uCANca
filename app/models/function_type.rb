class FunctionType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name           :string
    description    :text
    estimated_days :float
    timestamps
  end
  attr_accessible :name, :description, :estimated_days

  has_many :functions, :inverse_of => :function_type

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

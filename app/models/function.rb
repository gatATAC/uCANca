class Function < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ident :string
    name :string
    description :text
    timestamps
  end
  attr_accessible :ident, :name, :description, :function_type, :function_type_id

  belongs_to :function_type, :inverse_of => :functions

  has_many :function_sub_systems
  has_many :sub_systems, :through => :function_sub_systems

  children :function_sub_systems

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

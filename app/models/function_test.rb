class FunctionTest < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name             :string
    description      :text
    stimulus         :text
    expected_results :text
    timestamps
  end
  
  attr_accessible :name, :description, :stimulus, :expected_results

  belongs_to :function, :inverse_of => :function_sub_systems

  validates :function, :presence => :true

  acts_as_list :scope => :function

  # --- Permissions --- #

  def create_permitted?
    function.updatable_by?(acting_user)
  end

  def update_permitted?
    function.updatable_by?(acting_user)
  end

  def destroy_permitted?
    function.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    function.viewable_by?(acting_user)
  end

end

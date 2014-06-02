class FlowTypeTarget < ActiveRecord::Base

  hobo_model # Don't put anything above this

  include FlowTypeGen
  
  fields do
    name :string
    c_type :string
    c_setup_input_patron :text
    c_setup_output_patron :text
    c_input_patron :text
    c_output_patron :text
    enable_input :boolean, :default => true
    enable_output :boolean, :default => true
    arg_by_reference :boolean, :default => false
    custom_type :boolean, :default => false
    phantom_type :boolean, :default => false
    timestamps
  end
  attr_accessible :c_type, :c_input_patron, :c_output_patron, :c_setup_input_patron,:c_setup_output_patron, :enable_input, :enable_output, :arg_by_reference, :custom_type, :phantom_type, :flow_type_id, :flow_type, :target_id, :target

  belongs_to :flow_type
  belongs_to :target, :creator => :true

  def name
    return flow_type.name
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

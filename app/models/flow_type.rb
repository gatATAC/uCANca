class FlowType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  include FlowTypeGen
  
  fields do
    name :string
    c_type :string
    c_setup_input_patron :text
    c_setup_output_patron :text
    c_input_patron :text
    c_output_patron :text
    c_getter_patron :text
    c_setter_patron :text
    enable_input :boolean, :default => true
    enable_output :boolean, :default => true
    enable_getter :boolean, :default => true
    enable_setter :boolean, :default => true
    arg_by_reference :boolean, :default => false
    custom_type :boolean, :default => false
    phantom_type :boolean, :default => false
    
    # For calibration/conversion
    size          :integer
    A2l_type :string
    dataset_type :string
    parameter_set_type :string
    is_float  :boolean
    is_symbol :boolean
    A2L_symbol_code :text
    
    timestamps
  end
  attr_accessible :name, :c_type, :c_input_patron, :c_output_patron, :c_setup_input_patron, :c_setup_output_patron, :enable_input, 
    :enable_output, :arg_by_reference, :custom_type, :phantom_type, :c_getter_patron, :c_setter_patron, :enable_getter, :enable_setter,
    :size, :A2l_type, :dataset_type, :parameter_set_type, :is_float, :is_symbol, :A2L_symbol_code
  has_many :flows
  has_many :flow_type_targets
  has_many :datum_conversions
  
  validates :name, :presence => :true

  def to_a2l
    if is_symbol then
      return self.A2L_symbol_code+"\n"
    else
      return ""
    end
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
=begin
    ret=false
    if (field==:c_type ||
          field==:c_input_patron ||
          field==:c_output_patron ||
          field==:c_getter_patron ||
          field==:c_setter_patron ||
          field==:enable_input ||
          field==:enable_output ||
          field==:enable_getter ||          
          field==:enable_setter ||          
          field==:arg_by_reference ||
          field==:custom_type ||
          field==:phantom_type
        ) then
      ret=acting_user.developer?
    else
      ret=true
    end
    return ret
=end
    return true
  end
end

class DatumConversion < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name     :string
    convert  :boolean
    truncate :boolean
    factor   :float
    offset   :float
    timestamps
  end
  attr_accessible :name, :convert, :truncate, :factor, :offset, :flow_type, :flow_type_id, :project, :project_id

  belongs_to :project, :inverse_of => :datum_conversions
  belongs_to :flow_type
  has_many :datum_datum_conversions
  has_many :data, :through => :datum_datum_conversions
  
  validates :project, :presence => :true
  validates :flow_type, :presence => :true
  
  children :data

  def to_a2l
    if convert then
      r="/begin COMPU_METHOD "+name+".CONVERSION \"@@@@RuleName created by DRE code generator\"\n"
      r+="LINEAR \"%3.1\" \"\"\n"
      r+="COEFFS_LINEAR "+factor.to_s+" "+offset.to_s+"\n"
      r+="/end COMPU_METHOD\n"
    else
      r=""
    end
    return r
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

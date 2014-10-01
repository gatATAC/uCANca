class Datum < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name           :string
    description    :text
    min_phys_value :float
    max_phys_value :float
    typ_phys_value :float
    comment        :text
    generate       :boolean
    timestamps
  end
  
  attr_accessible :name, :description, :min_phys_value, :max_phys_value, :typ_phys_value,
    :comment, :generate, :flow, :flow_id, :datum_datum_conversions, :unit_id, :unit

  belongs_to :flow
  belongs_to :unit
  
  has_many :datum_datum_conversions
  has_many :datum_conversions, :through => :datum_datum_conversions, :accessible => true

  validates :flow, :presence => :true
  
  children :datum_datum_conversions, :datum_conversions
  
  
  def self.show_code
    @code="/**** AutoDiagnostics_calibration.h ****/\n"
    self.find(:all).each { |r|
      if (r.generate) then
        r.datum_datum_conversions.find(:all).each { |d|
          @code+=d.to_code_declaration;
        }
      end
    }
    @code+="\n\n/**** AutoDiagnostics_calibration.c ****/\n"
    self.find(:all).each { |r|
      if (r.generate) then
        r.datum_datum_conversions.find(:all).each { |d|
          @code+=d.to_code
        }
      end
    }
    return @code
  end

  def self.show_a2l
    @code =""
    FlowType.find(:all).each {|dt|
      @code+=dt.to_a2l+"\n"
    }
    DatumConversion.find(:all).each { |d|
      @code+=d.to_a2l+"\n"
    }
    @code+="\n"
    self.find(:all).each { |r|
      if (r.generate) then
        r.datum_datum_conversions.find(:all).each { |d|
          @code+=d.to_a2l+"\n"
        }
      end
    }
    return @code
  end

  def self.show_dataset_spec
    @code="Calibration list for AutoDiagnostics;;;;;;;;;;\n"
    @code+="Name;Parameter description;AutoSar Compliant;Min value;Max value;Typ value;Special vector;Unit;Data type;Size data;Resolution\n"
    self.find(:all).each { |r|
      if (r.generate) then
        r.datum_datum_conversions.find(:all).each { |d|
          @code+=d.to_dataset_spec+"\n"
        }
      end
    }
    return @code
  end
  def self.show_parameter_set
    @code="CANape PAR V3.1: INE_HONDA_DCU.a2l 1 0 CCP_DCU\n"
    @code+=";Parameter file created by DRE code generator\n;\n"
    self.find(:all).each { |r|
      if (r.generate) then
        r.datum_datum_conversions.find(:all).each { |d|
          @code+=d.to_parameter_set+"\n"
        }
      end
    }
    return @code
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

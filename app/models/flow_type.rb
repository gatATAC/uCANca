class FlowType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    c_type :string
    c_input_patron :text
    c_output_patron :text
    enable_input :boolean, :default => :true
    enable_output :boolean, :default => :true
    paso_por_referencia :boolean, :default => :false
    tipo_propio :boolean, :default => :false
    timestamps
  end
  attr_accessible :name, :c_type, :c_input_patron, :c_output_patron, :enable_input, :enable_output, :paso_por_referencia, :tipo_propio

  has_many :flows

=begin
  DIO
  ADC
  PWM
  CAN signal
  Status
  Timer
  Variable
  Bus
  NC
  Power
=end

  def to_c_type(f)
    ret=""
    if (!c_type || c_type.size<=0) then
      ret+="t_"+name.downcase
    else
      ret=c_type
    end
    if (tipo_propio) then
      ret="t_"+f.name.downcase
    end
    return ret
  end

  def to_c_input_decl(f)
    ret=to_c_input(f).split("{")[0]+";"
  end
  def to_c_output_decl(f)
    ret=to_c_output(f).split("{")[0]+";"
  end

  def to_c_output(f)
    if (enable_output) then
      if (c_output_patron) then
        ret=c_output_patron.gsub("%FLOW%", f.name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (paso_por_referencia) then
          ret=ret.gsub("%REF%","*")
        else
          ret=ret.gsub("%REF%","")
        end
        ret=ret.gsub("%TYP%",name)
      else
        ret="// (salida no implementada para el tipo #{name})"
      end
    else
      ret="// (salida no habilitada para el tipo #{name})"
    end
  end

  def to_c_input(f)
    if (enable_input) then
      if (c_input_patron) then
        ret=c_input_patron.gsub("%FLOW%", f.name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (paso_por_referencia) then
          ret=ret.gsub("%REF%","*")
        else
          ret=ret.gsub("%REF%","")
        end
        ret=ret.gsub("%TYP%",name)
      else
        ret="// (entrada no implementada para el tipo #{name})"
      end
    else
      ret="// (entrada no habilitada para el tipo #{name})"
    end
  end
  
  def to_c_output(f)
    if (enable_output) then
      if (c_output_patron) then
        ret=c_output_patron.gsub("%FLOW%", f.name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (paso_por_referencia) then
          ret=ret.gsub("%REF%","*")
        else
          ret=ret.gsub("%REF%","")
        end
        ret=ret.gsub("%TYP%",name)
      else
        ret="// (salida no implementada para el tipo #{name})"
      end
    else
      ret="// (salida no habilitada para el tipo #{name})"
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
    true
  end

end

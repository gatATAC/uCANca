class FlowType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    c_type :string
    c_input_patron :text
    c_output_patron :text
    enable_input :boolean, :default => true
    enable_output :boolean, :default => true
    paso_por_referencia :boolean, :default => false
    tipo_propio :boolean, :default => false
    tipo_fantasma :boolean, :default => false
    timestamps
  end
  attr_accessible :name, :c_type, :c_input_patron, :c_output_patron, :enable_input, :enable_output, :paso_por_referencia, :tipo_propio, :tipo_fantasma

  has_many :flows

  validates :name, :presence => :true

  def to_define(f)
    if (!tipo_fantasma) then
      return "#define "+f.name+" dre."+f.name+"\n"
    else
      return ""
    end
  end

  def to_c_type(f)
    if (tipo_fantasma) then
      ret="// "+name+" -- Does not need declaration"
    else
      ret=""
      if (!c_type || c_type.size<=0) then
        ret+="t_"+name.downcase
      else
        ret=c_type
      end
      if (tipo_propio) then
        ret="t_"+f.name.downcase
      end
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
        ret=c_output_patron.gsub("%FLOW%", f.c_name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (paso_por_referencia) then
          ret=ret.gsub("%REF%","*")
        else
          ret=ret.gsub("%REF%","")
        end
        ret=ret.gsub("%TYP%",name)
      else
        ret="// (output not implemented for #{name} type)"
      end
    else
      ret="// (output disabled for #{name} type)"
    end
  end

  def to_c_input(f)
    if (enable_input) then
      if (c_input_patron) then
        ret=c_input_patron.gsub("%FLOW%", f.c_name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (paso_por_referencia) then
          ret=ret.gsub("%REF%","*")
        else
          ret=ret.gsub("%REF%","")
        end
        ret=ret.gsub("%TYP%",name)
      else
        ret="// (input not implemented for #{name} type)"
      end
    else
      ret="// (input disabled for #{name} type)"
    end
  end
  
  def to_c_output(f)
    if (enable_output) then
      if (c_output_patron) then
        ret=c_output_patron.gsub("%FLOW%", f.c_name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (paso_por_referencia) then
          ret=ret.gsub("%REF%","*")
        else
          ret=ret.gsub("%REF%","")
        end
        ret=ret.gsub("%TYP%",name)
      else
        ret="// (output not implemented for #{name} type)"
      end
    else
      ret="// (output disabled for #{name} type)"
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
          field==:enable_input ||
          field==:enable_output ||
          field==:paso_por_referencia ||
          field==:tipo_propio ||
          field==:tipo_fantasma
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

module FlowTypeGen
    

  def to_define(f)
    if (!phantom_type) then
      return "#define "+f.name+" dre."+f.name+"\n"
    else
      return ""
    end
  end

  def to_c_type(f)
    if (phantom_type) then
      ret="// "+name+" -- Does not need declaration"
    else
      ret=""
      if (!c_type || c_type.size<=0) then
        ret+="t_"+name.downcase
      else
        ret=c_type
      end
      if (custom_type) then
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

  def to_c_setup_input(f)
    if (enable_input) then
      if (c_setup_input_patron) then
        ret=c_setup_input_patron.gsub("%FLOW%", f.c_name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (arg_by_reference) then
          ret=ret.gsub("%REF%","*")
        else
          ret=ret.gsub("%REF%","")
        end
        ret=ret.gsub("%TYP%",name)
      else
        ret="// (setup input not implemented for #{name} type)"
      end
    else
      ret="// (setup input disabled for #{name} type)"
    end
  end  
  
  def to_c_input(f)
    if (enable_input) then
      if (c_input_patron) then
        ret=c_input_patron.gsub("%FLOW%", f.c_name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (arg_by_reference) then
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
  
  def to_c_setup_output(f)
    if (enable_output) then
      if (c_setup_output_patron) then
        ret=c_setup_output_patron.gsub("%FLOW%", f.c_name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (arg_by_reference) then
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
  
  def to_c_output(f)
    if (enable_output) then
      if (c_output_patron) then
        ret=c_output_patron.gsub("%FLOW%", f.c_name)
        ret=ret.gsub("%CTYP%",to_c_type(f))
        if (arg_by_reference) then
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
  
  
end

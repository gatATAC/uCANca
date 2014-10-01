class DatumDatumConversion < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  attr_accessible :datum, :datum_id, :datum_conversion, :datum_conversion_id, :conversion_target, :conversion_target_id

  belongs_to :datum, :creator => true
  belongs_to :datum_conversion
  belongs_to :conversion_target

  def to_code
    if datum_conversion.truncate then
      value=datum.typ_phys_value.to_i.to_s
    else
      value=datum.typ_phys_value.to_s
    end
    r=""
    r+=datum_conversion.flow_type.c_type+" "
    if (datum_conversion.convert) then
      r+=datum.name+"=("+datum_conversion.flow_type.c_type+")(("+value+"-("+datum_conversion.offset.to_s+"))/"+datum_conversion.factor.to_s+");\n"
    else
      r+=datum.name+"=("+datum_conversion.flow_type.c_type+")"+value+";\n"
    end
  end

  def to_code_declaration
    r="extern "
    r+=datum_conversion.flow_type.c_type+" "
    r+=datum.name+";\n"
  end

  def calculate_a2l_conversion
    if (datum_conversion.convert) then
      return datum_conversion.name+".CONVERSION "
    else
      if (datum_conversion.flow_type.is_symbol) then
        return datum_conversion.name
      else
        return "NO_COMPU_METHOD"
      end
    end
  end

  def to_min_str
    if datum_conversion.truncate then
      value=datum.min_phys_value.to_i.to_s
    else
      value=datum.min_phys_value.to_s
    end
    return value
  end

  def to_max_str
    if datum_conversion.truncate then
      value=datum.max_phys_value.to_i.to_s
    else
      value=datum.max_phys_value.to_s
    end
    return value
  end

  def to_a2l
    r="/begin CHARACTERISTIC "+datum.name+" \""+datum.description+"\"\n"
    r+="VALUE 0x400010A4 __"+datum_conversion.flow_type.A2l_type+"_S 0 "+calculate_a2l_conversion+" "+to_min_str+" "+to_max_str+"\n"
    r+="ECU_ADDRESS_EXTENSION 0x0\n"
    r+=" EXTENDED_LIMITS  "+to_min_str+" "+to_max_str+"\n"
    r+=" BYTE_ORDER MSB_FIRST\n"
    r+=" FORMAT \"%.15\"\n"
    r+=" /begin IF_DATA CANAPE_EXT\n"
    r+="100\n"
    r+="LINK_MAP \""+datum.name+"\" 0x00000000 0x0 0 0x0 1 0x9F 0x0\n"
    r+="DISPLAY 0 "+to_min_str+" "+to_max_str+"\n"
    r+="/end IF_DATA\n"
    r+="SYMBOL_LINK \""+datum.name+"\" 0\n"
    r+="PHYS_UNIT \""+datum.unit.abbrev+"\"\n"
    r+="/end CHARACTERISTIC\n"
  end

  def to_dataset_spec
    if datum_conversion.truncate then
      value=datum.typ_phys_value.to_i.to_s
    else
      value=datum.typ_phys_value.to_s
    end
    ret=datum.name+";"
    ret+=datum.description+";"
    ret+="Not Assigned;"
    ret+=datum.min_phys_value.to_s+";"
    ret+=datum.max_phys_value.to_s+";"
    ret+=value+";"
    ret+="N;"
    ret+=datum.unit.abbrev+";"
    ret+=datum_conversion.flow_type.dataset_type+";"
    ret+="1;"
    ret+=datum_conversion.factor.to_s
    return ret
  end

  def calculate_raw_value
    if (datum_conversion.convert) then
      aux=(datum.typ_phys_value-+datum_conversion.offset)/datum_conversion.factor
      if datum_conversion.flow_type.is_float then
        raw_value=aux.to_i
      else
        raw_value=aux
      end
    else
      raw_value=datum.typ_phys_value
    end
    return raw_value
  end

  def raw_value_to_s
    if datum_conversion.flow_type.is_float then
      calculate_raw_value.to_s
    else
      calculate_raw_value.to_i.to_s
    end
  end

  def value_to_s
    if datum_conversion.truncate then
      value=datum.typ_phys_value.to_i.to_s
    else
      value=datum.typ_phys_value.to_s
    end
    return value
  end

  def to_parameter_set
    r=""
    r+=datum.name+" ["
    r+=datum_conversion.flow_type.parameter_set_type+"] "
    r+=raw_value_to_s+" ; "+value_to_s
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

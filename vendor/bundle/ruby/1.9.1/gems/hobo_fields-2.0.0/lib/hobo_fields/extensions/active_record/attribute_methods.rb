ActiveRecord::Base.class_eval do
  class << self

    def can_wrap_with_hobo_type?(attr_name)
      if connected?
        type_wrapper = try.attr_type(attr_name)
        type_wrapper.is_a?(Class) && type_wrapper.not_in?(HoboFields::PLAIN_TYPES.values)
      else
        false
      end
    end

    # Rails 3.2+
    def internal_attribute_access_code(attr_name, cast_code)
      access_code = "(v=@attributes[attr_name]) && #{cast_code}"

      unless attr_name == primary_key
        access_code.insert(0, "missing_attribute(attr_name, caller) unless @attributes.has_key?(attr_name); ")
      end

      # This is the Hobo hook - add a type wrapper around the field
      # value if we have a special type defined
      if can_wrap_with_hobo_type?(attr_name)
        access_code = "val = begin; #{access_code}; end; wrapper_type = self.class.attr_type(:#{attr_name}); " +
            "if HoboFields.can_wrap?(wrapper_type, val); wrapper_type.new(val); else; val; end"
      end

      if cache_attribute?(attr_name)
        access_code = "@attributes_cache['#{attr_name}'] ||= begin; #{access_code}; end;"
      end

      "attr_name = '#{attr_name}'; #{access_code}"
    end

    # Rails 3.1 or earlier
    # Define an attribute reader method.  Cope with nil column.
    def define_read_method(symbol, attr_name, column)
      cast_code = column.type_cast_code('v') if column
      access_code = cast_code ? "(v=@attributes['#{attr_name}']) && #{cast_code}" : "@attributes['#{attr_name}']"

      unless attr_name.to_s == self.primary_key.to_s
        access_code = access_code.insert(0, "missing_attribute('#{attr_name}', caller) unless @attributes.has_key?('#{attr_name}'); ")
      end

      # This is the Hobo hook - add a type wrapper around the field
      # value if we have a special type defined
      if can_wrap_with_hobo_type?(symbol)
        access_code = "val = begin; #{access_code}; end; wrapper_type = self.class.attr_type(:#{attr_name}); " +
            "if HoboFields.can_wrap?(wrapper_type, val); wrapper_type.new(val); else; val; end"
      end

      if cache_attribute?(attr_name)
        access_code = "@attributes_cache['#{attr_name}'] ||= begin; #{access_code}; end;"
      end

      generated_attribute_methods.module_eval("def #{symbol}; #{access_code}; end", __FILE__, __LINE__)
    end

    def define_method_attribute=(attr_name)
      if can_wrap_with_hobo_type?(attr_name)
        src = "begin; wrapper_type = self.class.attr_type(:#{attr_name}); " +
          "if !new_value.is_a?(wrapper_type) && HoboFields.can_wrap?(wrapper_type, new_value); wrapper_type.new(new_value); else; new_value; end; end"
        generated_attribute_methods.module_eval("def #{attr_name}=(new_value); write_attribute('#{attr_name}', #{src}); end", __FILE__, __LINE__)
      else
        super
      end
    end

  end
end

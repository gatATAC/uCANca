module Dryml

  class TemplateEnvironment

    class << self
      def inherited(subclass)
        subclass.compiled_local_names = []
      end
      attr_accessor :load_time, :compiled_local_names


      def _register_tag_attrs(tag_name, attrs)
        @tag_attrs ||= {}
        @tag_attrs[tag_name] = attrs
      end


      def tag_attrs
        @tag_attrs ||= {}
      end

      alias_method :delayed_alias_method_chain, :alias_method_chain

    end

    include Helper  ## FIXME remove

    def initialize(view=nil)
      unless view.nil?
        @view = view
        @_erb_binding = binding
        @_part_contexts = {}
        @_scoped_variables = ScopedVariables.new
        @_polymorphic_tag_cache = {}

        # Make sure the "assigns" from the controller are available (instance variables)
        if view
          view.assigns.each do |key, value|
            instance_variable_set("@#{key}", value)
          end

          # copy view instance variables over
          view.instance_variables.each do |iv|
            instance_variable_set(iv, view.instance_variable_get(iv))
          end
        end
      end
    end

    for attr in [:erb_binding, :part_contexts,
                 :this, :this_parent, :this_field, :this_key,
                 :form_this, :form_field_path, :form_field_names]
      class_eval "def #{attr}; @_#{attr}; end"
    end

    def path_for_form_field
      @_form_field_path.nil? and raise Dryml::DrymlException,
        "DRYML cannot provide the correct form-field name here (this_field = #{this_field.inspect}, this = #{this.inspect})"
      @_form_field_path
    end


    def this_key=(key)
      @_this_key = key
    end


    # The type of this, or when this is nil, the type that would be expected in the current field
    def this_type
      @_this_type ||= if this == false || this == true
                        Hobo::Boolean
                      elsif this
                        this.class
                      elsif this_parent && this_field && (parent_class = this_parent.class).respond_to?(:attr_type)
                        type = parent_class.attr_type(this_field)
                        if type.is_a?(ActiveRecord::Reflection::AssociationReflection)
                          reflection = type
                          if reflection.macro == :has_many
                            Array
                          elsif reflection.options[:polymorphic]
                            # All we know is that it will be some active-record type
                            ActiveRecord::Base
                          else
                            reflection.klass
                          end
                        else
                          type
                        end
                      else
                        # Nothing to go on at all
                        Object
                      end
    end


    def this_field_reflection
      this.try.proxy_association._?.reflection ||
        (this_parent && this_field && this_parent.class.respond_to?(:reflections) && this_parent.class.reflections[this_field.to_sym])
    end


    def attrs_for(name)
      self.class.tag_attrs[name.to_sym]
    end


    def deunderscore_attributes(attrs)
      HashWithIndifferentAccess[attrs.map{ |attr, value| [attr.to_s.gsub('_', '-'), value]}]
    end

    def add_classes!(attributes, *classes)
      classes = classes.flatten.select{|x|x}
      current = attributes[:class]
      attributes[:class] = (current ? current.split + classes : classes).uniq.join(' ')
      attributes
    end

    def add_classes(attributes, *classes)
      add_classes!(HashWithIndifferentAccess.new(attributes), classes)
    end

    def remove_classes!(attributes, *remove_classes)
      if attributes[:class]
        attributes[:class] = (attributes[:class].split - remove_classes).join(' ')
      end
      attributes
    end

    def add_data_rapid!(attrs, tag, options)
      data_rapid = ActiveSupport::JSON.decode(attrs["data_rapid"] || "{}")
      attrs["data_rapid"] = data_rapid.update(tag => options).to_json
      attrs
    end

    def add_data_rapid(attrs, tag, options)
      add_data_rapid!(HashWithIndifferentAccess.new(attrs), tag, options)
    end

    def merge_attrs(attrs, overriding_attrs)
      attrs = {}.update(attrs)
      return attrs if overriding_attrs.nil?
      attrs = attrs.with_indifferent_access unless attrs.is_a?(HashWithIndifferentAccess)
      classes = overriding_attrs[:class]
      add_classes!(attrs, *classes.split) if classes
      remove_classes!(attrs, *(overriding_attrs[:remove_class].split)) if overriding_attrs[:remove_class]
      if (data_rapid = overriding_attrs["data_rapid"])
        attrs["data_rapid"]=ActiveSupport::JSON.decode(attrs["data_rapid"] || "{}").
          update(ActiveSupport::JSON.decode(data_rapid)).to_json
      end

      attrs.update(overriding_attrs - [:class, :data_rapid])
    end


    def scope
      @_scoped_variables
    end


    def typed_id(object=nil, attribute=nil)
      if object.nil?
        # nothing passed -- use context
        if this_parent && this_field && !this_parent.respond_to?(:member_class)
          object, attribute = this_parent, this_field
        else
          object = this
        end
      end

      id = if (!object.is_a?(ActiveRecord::Relation) && typed_id = object.try.typed_id)
             typed_id
           elsif object == @this
             "this"
           end
      attribute ? "#{id}:#{attribute}" : id
  end


    def call_part(part_node_id, part_name, *locals)
      res = ''
      new_context do
        @_part_contexts[part_node_id] = PartContext.for_call(part_name, self, locals)
        res = send("#{part_name}_part", *locals)
      end
      res
    end


    def refresh_part(encoded_context, session, dom_id)
      context = Dryml::PartContext.for_refresh(encoded_context, @this, session)

      with_part_context(context) do
        send("#{context.part_name}_part", *context.locals)
      end
    end


    def with_part_context(context, &block)
      this, this_field = context.this, context.this_field

      b = if context.form_field_path
            proc { with_form_context(:unknown, context.form_field_path, &block) }
          else
            block
          end

      if this && this_field
        new_object_context(this) { new_field_context(this_field, &b) }
      elsif this
        new_object_context(this, &b)
      else
        new_context(&b)
      end
    end

    def parse_for_type(attributes)
      t = attributes[:for_type]
      if t.nil?
        nil
      elsif t.is_a?(Class)
        t
      elsif t =~ /^[A-Z]/
        t.constantize
      elsif t =~ /^[a-z]/ && defined?(HoboFields.to_class)
        HoboFields.to_class(t)
      else
        nil
      end
    end

    def call_polymorphic_tag(name, *args)
      name = name.to_s.gsub('-', '_')
      type = args.first.is_a?(Class) ? args.shift : nil
      attributes, parameters = args

      tag = find_polymorphic_tag(name, type)
      if tag != name
        send(tag, attributes || {}, parameters || {})
      else
        block_given? ? yield : nil
      end
    end


    def find_polymorphic_tag(name, call_type=nil)
      call_type ||= (this.respond_to?(:member_class) && this.member_class) || this_type
      begin
        found = nil
        while true
          # ActiveSupport::TimeWithZone.name would return 'Time'
          # so we add an exception to pick the right datetime type
          type_name = ( call_type == ActiveSupport::TimeWithZone ? 'datetime' : call_type.name.to_s).underscore.gsub('/', '__')
          if respond_to?(poly_name = "#{name}__for_#{type_name}")
            found = poly_name
            break
          else
            if call_type == Object
              found = name
              break
            else
              call_type = call_type.superclass
            end
          end
        end
        found
      end
    end


    def repeat_attribute(string_or_array)
      res = nil
      if string_or_array.instance_of?(String)
        new_field_context(string_or_array) do
           res = context_map { yield }
         end
      else
        res = context_map(string_or_array) { yield }
      end
      res.safe_join
    end


    def new_context
      ctx = [ @_this, @_this_parent, @_this_field, @_this_type,
              @_form_field_path, @_form_field_paths_by_object ]
      @_this_type = nil
      res = nil
      outer_res = @view.with_output_buffer { res = yield }
      Rails.logger.error("new_context: #{caller.first}") if !outer_res.blank? && outer_res.to_s != res.to_s
      @_this, @_this_parent, @_this_field, @_this_type, @_form_field_path, @_form_field_paths_by_object = ctx
      res.to_s
    end

    def yield_output_buffer
      res = nil
      @view.with_output_buffer { res = yield }
      res.to_s
    end


    def new_object_context(new_this)
      new_context do
        if new_this.respond_to?(:origin)
          refl = (new_this.origin && new_this.origin_attribute.is_a?(Symbol) && new_this.origin.class.respond_to?(:reflections) && new_this.origin.class.reflections[new_this.origin_attribute])
          if refl.nil? || refl.macro==:belongs_to || refl.macro==:has_one
            @_this_parent, @_this_field = new_this.origin, new_this.origin_attribute
          else
            # See bug #989 for more discussion.   The commented out
            # section is more 'correct', but it is expensive and since
            # nobody really ran into this before, setting to nil seems
            # more appropriate.
            @_this_parent, @_this_field = nil, nil
            #@_this_parent = new_this.origin.send(new_this.origin_attribute)
            #@_this_field = @_this_parent.index(new_this) || @_this_parent.length
          end
        else
          @_this_parent, @_this_field = [nil, nil]
        end
        @_this = new_this

        # We might have lost track of where 'this' is relative to the form_this
        # check if this or this_parent are objects we've seen before in this form
        @_form_field_path = find_form_field_path(new_this) if @_form_field_path

        yield
      end
    end


    def new_field_context(field_path, new_this=nil)
      new_context do
        path = if field_path.is_a? String
                 field_path.split('.')
               else
                 Array(field_path)
               end
        if new_this
          raise ArgumentError, "invlaid context change" unless path.length == 1
          @_this_parent, @_this_field, @_this = this, path.first, new_this
        else
          parent, field, obj = Dryml.get_field_path(this, path)
          @_this, @_this_parent, @_this_field = obj, parent, field
        end

        if @_form_field_path
          @_form_field_path += path
          @_form_field_paths_by_object[@_this] = @_form_field_path
        end

        yield
      end
    end


    def find_form_field_path(object)
      back = []
      while object
        path = @_form_field_paths_by_object[object]
        if path
          path = path + back unless back.empty?
          return path
        end
        if object.respond_to? :origin
          back.unshift object.origin_attribute
          object = object.origin
        else
          return nil
        end
      end
    end




    def _tag_context(attributes)
      with  = attributes[:with]
      field = attributes[:field]

      if with && field
        new_object_context(with) { new_field_context(field) { yield } }
      elsif field
        new_field_context(field) { yield }
      elsif attributes.has_key?(:with)
        new_object_context(with) { yield }
      else
        new_context { yield }
      end
    end


    def with_form_context(form_this=this, form_field_path=[form_this.class.name.underscore])
      ctx = [@_form_this, @_form_field_path, @_form_field_paths_by_object]
      @_form_this = form_this
      @_form_field_path = form_field_path
      @_form_field_paths_by_object = { form_this => form_field_path }
      res = scope.new_scope :in_form => true, :form_field_names => [] do
        yield
      end
      @_form_this, @_form_field_path, @_form_field_paths_by_object = ctx
      res
    end


    def register_form_field(name)
      scope.form_field_names << name
    end


    def _tag_locals(attributes, locals)
      attributes = attributes.symbolize_keys
      #ensure with and field are not in attributes
      attributes.delete(:with)
      attributes.delete(:field)

      # declared attributes don't appear in the attributes hash
      stripped_attributes = HashWithIndifferentAccess.new.update(attributes)
      locals.each {|a| stripped_attributes.delete(a.to_sym) }

      # Return locals declared as local variables (attrs="...")
      locals.map {|a| attributes[a.to_sym]} + [stripped_attributes]
    end


    def call_tag_parameter_with_default_content(the_tag, attributes, default_content, overriding_content_proc)
      if the_tag.is_one_of?(String, Symbol) && the_tag.to_s.in?(Dryml.static_tags)
        body = if overriding_content_proc
                 new_context { overriding_content_proc.call(proc { default_content._?.call(nil) }) }
               elsif default_content
                 new_context { default_content.call(nil) }
               else
                 nil
               end
        element(the_tag, attributes, body)
      else
        d = if overriding_content_proc
              proc { |default| overriding_content_proc.call(proc { default_content._?.call(default) }) }
            else
              proc { |default| default_content._?.call(default) }
            end
        send(the_tag, attributes, { :default => d })
      end
    end


    def call_tag_parameter(the_tag, attributes, parameters, caller_parameters, param_name)
      overriding_proc = caller_parameters[param_name]
      replacing_proc  = caller_parameters[:"#{param_name}_replacement"]

      unless param_name == the_tag || param_name == :default
        classes = attributes[:class]
        param_class = param_name.to_s.gsub('_', '-')
        attributes[:class] = if classes
                               classes =~ /\b#{param_class}\b/ ? classes : "#{classes} #{param_class}"
                             else
                               param_class
                             end
      end

      if param_name == :default && overriding_proc && overriding_proc.arity>0
        # :default content is handled specially

        call_tag_parameter_with_default_content(the_tag, attributes, parameters[:default], overriding_proc)

      elsif replacing_proc
        # The caller is replacing this parameter. Don't call the tag
        # at all, just the overriding proc, but pass the restorable
        # tag as a parameter to the overriding proc

        tag_restore = proc do |restore_attrs, restore_params|
          # Call the replaced tag with the attributes and parameters
          # as given in the original tag definition, and with the
          # specialisation given on the 'restore' call

          if overriding_proc
            overriding_attributes, overriding_parameters = overriding_proc.call
            restore_attrs  = overriding_attributes.merge(restore_attrs)
            restore_params = overriding_parameters.merge(restore_params)
          end

          override_and_call_tag(the_tag, attributes, parameters, restore_attrs, restore_params)
        end
        replacing_proc.call(tag_restore)

      else
        overriding_attributes, overriding_parameters = overriding_proc._?.call
        override_and_call_tag(the_tag, attributes, parameters, overriding_attributes, overriding_parameters)
      end
    end


    def override_and_call_tag(the_tag, general_attributes, general_parameters, overriding_attributes, overriding_parameters)
      attributes = overriding_attributes ? merge_attrs(general_attributes, overriding_attributes) : general_attributes
      if overriding_parameters
        overriding_default_content = overriding_parameters.delete(:default)
        parameters = general_parameters.merge(overriding_parameters)
      else
        parameters = general_parameters
      end

      default_content = parameters[:default]

      if the_tag.is_one_of?(String, Symbol) && the_tag.to_s.in?(Dryml.static_tags)
        body = if overriding_default_content
                 new_context { overriding_default_content.call(proc { default_content.call(nil) if default_content }) }
               elsif default_content
                 new_context { default_content.call(nil) }
               else
                 nil
               end
        element(the_tag, attributes, body)
      else
        if default_content || overriding_default_content
          d = if overriding_default_content
                proc { |default| overriding_default_content.call(proc { default_content.call(default) if default_content }) }
              else
                proc { |default| default_content.call(default) if default_content }
              end
          parameters = parameters.merge(:default => d)
        end

        if the_tag.is_one_of?(String, Symbol)
          # It's a defined DRYML tag
          send(the_tag, attributes, parameters)
        else
          # It's a proc - restoring a replaced parameter
          the_tag.call(attributes, parameters)
        end
      end
    end


    # This method is used where 'param' is declared on a tag that is
    # itself a parameter tag.  Takes two procs that each return a pair
    # of hashes (attributes and parameters). Returns a single proc
    # that also returns a pair of hashes - the merged atributes and
    # parameters.
    def merge_tag_parameter(general_proc, overriding_proc)
      if overriding_proc.nil?
        general_proc
      else
        if overriding_proc.arity == 1
          # The override is a replace parameter - just pass it on
          overriding_proc
        else
          proc do
            overriding_attrs, overriding_parameters = overriding_proc.call
            general_attrs, general_parameters = general_proc.call

            attrs  = merge_attrs(general_attrs, overriding_attrs)
            overriding_default = overriding_parameters.delete(:default)
            params = merge_parameter_hashes(general_parameters, overriding_parameters)

            # The overrider should provide its :default as the new
            # 'default_content'
            if overriding_default
              params[:default] =
                if general_parameters[:default]
                  proc do |default|
                    overriding_default.call(proc { new_context { concat(general_parameters[:default].call(default)) } } )
                  end
                else
                  proc do |default|
                    overriding_default.call(default)
                  end
                end
            end

            [attrs, params]
          end
        end
      end
    end


    def merge_parameter_hashes(given_parameters, overriding_parameters)
      to_merge = given_parameters.keys & overriding_parameters.keys
      no_merge = overriding_parameters.keys - to_merge
      result = given_parameters.dup

      no_merge.each { |k| result[k] = overriding_parameters[k] }
      to_merge.each { |k| result[k] = merge_tag_parameter(given_parameters[k], overriding_parameters[k])}

      result
    end


    def part_contexts_storage_uncoded
      PartContext.client_side_storage_uncoded(@_part_contexts, session)
    end

    def render_tag(tag_name, attributes)
      method_name = tag_name.to_s.gsub('-', '_')
      if respond_to?(method_name)
        send(method_name, attributes).strip
      else
        false
      end
    end


    def element(name, attributes, content=nil, escape = true, empty = false, &block)
      unless attributes.blank?
        attrs = []
        if escape
          attributes.each do |key, value|
            next unless value
            key = key.to_s.gsub("_", "-")

            value = if ActionView::Helpers::TagHelper::BOOLEAN_ATTRIBUTES.include?(key)
                      key
                    else
                      # escape once
                      value.to_s.gsub(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/) { |special| ERB::Util::HTML_ESCAPE[special] }
                    end
            attrs << %(#{key}="#{value}")
          end

        else
          attrs = options.map do |key, value|
            key = key.to_s.gsub("_", "-")
            %(#{key}="#{value}")
          end
        end
        attr_string = " #{attrs.sort * ' '}" unless attrs.empty?
      end
      content = capture { new_context &block } if block_given?
      if empty
        "<#{name}#{attr_string}#{scope.xmldoctype ? ' /' : ''}>".html_safe
      else
        "<#{name}#{attr_string}>".html_safe + content + "</#{name}>".html_safe
      end
    end


    def session
      @view ? @view.session : {}
    end


    def method_missing(name, *args, &b)
      if @view
        @view.send(name, *args, &b)
      else
        raise NoMethodError, name.to_s
      end
    end

  end

end

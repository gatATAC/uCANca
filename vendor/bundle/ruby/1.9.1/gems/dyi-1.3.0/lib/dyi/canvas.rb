# -*- encoding: UTF-8 -*-

# Copyright (c) 2009-2012 Sound-F Co., Ltd. All rights reserved.
#
# Author:: Mamoru Yuo
#
# This file is part of DYI.
#
# DYI is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DYI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DYI.  If not, see <http://www.gnu.org/licenses/>.

#
module DYI

  # The body of Vector-Image. This class is a container for all graphical
  # elements that make up the image.
  # @since 0.0.0
  class Canvas < GraphicalElement

    # @private
    IMPLEMENT_ATTRIBUTES = [:view_box, :preserve_aspect_ratio]

    # Returns width of the vector-image on user unit.
    attr_length :width

    # Returns heigth of the vector-image on user unit.
    attr_length :height

    # @attribute view_box
    # Returns the value of the view_box.
    # @return [String]
    #+++
    # @attribute preserve_aspect_ratio
    # Returns the value of the preserve_aspect_ratio.
    # @return [String] the value of preserve_aspect_ratio
    attr_reader *IMPLEMENT_ATTRIBUTES

    # Returns an array of child elements.
    # @return [Array<Element>] an array of child elements
    attr_reader :child_elements

    # Returns hash of event listners.
    # @return [Hash] hash of event listners
    # @since 1.0.0
    attr_reader :event_listeners

    # Returns an array of stylesheets.
    # @return [Array<Stylesheet::Style>] an array of stylesheets
    # @since 1.0.0
    attr_reader :stylesheets

    # Returns an array of scripts.
    # @return [Array<Script::SimpleScript>] an array of scripts
    # @since 1.0.0
    attr_reader :scripts

    # Returns a metadata object that the image has.
    # @return [Object] a metadata object that the image has.
    # @since 1.1.1
    attr_accessor :metadata

    # @param [Length] width width of the canvas on user unit
    # @param [Length] height height of the canvas on user unit
    # @param [Length] real_width width of the image. When this value
    #   is nil, uses a value that equals value of width parameter.
    # @param [Length] real_height height of the image. When this value
    #   is nil, uses a value that equals value of height parameter.
    # @param [String] preserve_aspect_ratio value that indicates
    #   whether or not to force uniform scaling
    # @option options [String] :css_class CSS class of body element
    def initialize(width, height,
                   real_width = nil, real_height = nil,
                   preserve_aspect_ratio='none', options={})
      self.width = width
      self.height = height
      @view_box = "0 0 #{width} #{height}"
      @preserve_aspect_ratio = preserve_aspect_ratio
      @child_elements = []
      @scripts = []
      @event_listeners = {}
      @stylesheets = []
      @seed_of_id = -1
      @receive_event = false
      self.css_class = options[:css_class]
      self.real_width = real_width
      self.real_height = real_height
    end

    # Returns width of the image.
    # @return [Length] width of the image
    def real_width
      @real_width || width
    end

    # Sets width of the image.
    # @param [Length] width width of the image
    def real_width=(width)
      @real_width = Length.new_or_nil(width)
    end

    # Returns height of the image.
    # @return [Length] height of the image
    def real_height
      @real_height || height
    end

    # Sets height of the image.
    # @param [Length] height height of the image
    def real_height=(height)
      @real_height = Length.new_or_nil(height)
    end

    # @deprecated Use {#root_element?} instead.
    def root_node?
      msg = [__FILE__, __LINE__, ' waring']
      msg << ' DYI::Canvas#root_node? is deprecated; use DYI::Canvas#root_element?'
      warn(msg.join(':'))
      true
    end

    # Returns whether this instance is root element of the shape.
    # @return [Boolean] always true.
    # @since 1.0.0
    def root_element?
      true
    end

    # Returns the canvas where the shape is drawn.
    # @return [Canvas] itself
    # @since 1.0.0
    def canvas
      self
    end

    # Writes image on io object.
    # @param [Formatter::Base] formatter an object that defines the image format
    # @param [IO] io an io to be written
    # @since 1.0.0
    def write_as(formatter, io=$>)
      formatter.write_canvas(self, io)
    end

    # Saves as image file.
    # @param [String] file_name a name of an image file
    # @param [Symbol] format an image format. When this parameter is nil, saves
    #   as SVG. This method supports following values: :svg, :eps, :xaml, :png
    # @option options [Integer] :indent indent of XML output. Defualt to 2
    # @since 1.0.0
    def save(file_name, format=nil, options={})
      get_formatter(format, options).save(file_name)
    end

    # Puts in io.
    # @param [Symbol] format an image format. When this parameter is nil, saves
    #   as SVG. This method supports following values: :svg, :eps, :xaml, :png
    # @param [IO] io an io to be written
    # @option options [Integer] :indent indent of XML output. Defualt to 2
    # @since 1.0.0
    def puts_in_io(format=nil, io=$>, options={})
      get_formatter(format, options).puts(io)
    end

    # Returns data that means the image.
    # @param [Symbol] format an image format. When this parameter is nil, saves
    #   as SVG. This method supports following values: :svg, :eps, :xaml, :png
    # @option options [Integer] :indent indent of XML output. Defualt to 2
    # @return [String] data that means the image
    # @since 1.0.0
    def string(format=nil, options={})
      get_formatter(format, options).string
    end

    # Returns optional attributes.
    # @return [Hash] optional attributes
    def attributes
      IMPLEMENT_ATTRIBUTES.inject({}) do |hash, attribute|
        variable_name = '@' + attribute.to_s.split(/(?=[A-Z])/).map{|str| str.downcase}.join('_')
        value = instance_variable_get(variable_name)
        hash[attribute] = value.to_s if value
        hash
      end
    end

    # Create a new id for a descendant element.
    # @return [String] new id for a descendant element
    # @since 1.0.0
    def publish_shape_id
      'elm%04d' % (@seed_of_id += 1)
    end

    # Sets event to the image.
    # @param [Event] event an event that is set to this image
    # @since 1.0.0
    def set_event(event)
      super
      @receive_event = true
    end

    # Returns whether an event is set to the shape.
    # @return [Boolean] true if an event set to the shape, false otherwise.
    # @since 1.0.0
    def receive_event?
      @receive_event
    end

    # Registers a script.
    # @param [String, Script::SimpleScript] script_body a string that is a
    #   script body or a script object that is registered
    # @param [String] content_type a content-type of the script. If parameter
    #   'script_body' is {Script::SimpleScript} object, this parameter is ignored
    # @since 1.0.0
    def add_script(script_body, content_type = 'application/ecmascript')
      if script_body.respond_to?(:include_external_file?)
        @scripts << script_body unless @scripts.include?(script_body)
      else
        @scripts << Script::SimpleScript.new(script_body, content_type)
      end
    end

    # Registers a reference to a script file with the image.
    # @param [String] reference_path a file path of a script file
    # @param [String] content_type a content-type of the script
    # @since 1.0.0
    def reference_script_file(reference_path, content_type = 'application/ecmascript')
      @scripts << Script::ScriptReference.new(reference_path, content_type)
    end

    # Registers a stylesheet with the image.
    # @param [String] style_body a string that is a stylesheet body
    # @param [String] content_type a content-type of the stylesheet
    # @since 1.0.0
    def add_stylesheet(style_body, content_type = 'text/css')
      @stylesheets << Stylesheet::Style.new(style_body, content_type)
    end

    # Registers a reference to a stylesheet file with the image.
    # @param [String] reference_path a file path of a stylesheet file
    # @param [String] content_type a content-type of the stylesheet
    # @since 1.0.0
    def reference_stylesheet_file(reference_path, content_type = 'text/css')
      @stylesheets << Stylesheet::StyleReference.new(reference_path, content_type)
    end

    # Registers a script with the image for initialization.
    # @param [String] script_body a string that is a script body for
    #   initialization
    # @since 1.0.0
    def add_initialize_script(script_body)
      if @init_script
        @init_script.append_body(script_body)
      else
        @init_script = Script::EcmaScript::EventListener.new(script_body)
        add_event_listener(:load, @init_script)
      end
    end

    # @since 1.3.0
    def to_reused_source
      options = {}
      options[:css_class] = css_class
      template = Shape::GraphicalTemplate.new(width, height, preserve_aspect_ratio, options)
      template.instance_variable_set('@child_elements', child_elements)
      template
    end

    private

    def get_formatter(format=nil, options={})
      case format
        when :svg, nil
          options[:indent] = 2 unless options.key?(:indent)
          Formatter::SvgFormatter.new(self, options)
        when :xaml
          options[:indent] = 2 unless options.key?(:indent)
          Formatter::XamlFormatter.new(self, options)
        when :eps then Formatter::EpsFormatter.new(self)
        when :png then Formatter::PngFormatter.new(self)
        else raise ArgumentError, "`#{format}' is unknown format"
      end
    end
  end
end

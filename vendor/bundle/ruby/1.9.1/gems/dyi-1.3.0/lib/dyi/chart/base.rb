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

require 'csv'

module DYI
  module Chart

    # @private
    # @since 1.0.0
    module OptionCreator

      # Difines a read property.
      # @param [Symbol] name the property name
      # @param [Hash] settings settings of the property
      def opt_reader(name, settings = {})
        name = name.to_sym
        getter_name = settings[:type] == :boolean ? name.to_s.gsub(/^(.*[^=\?])[=\?]*$/, '\1?') : name
        if settings.key?(:default)
          define_method(getter_name) {@options.key?(name) ? @options[name] : settings[:default]}
        elsif settings.key?(:default_method)
          define_method(getter_name) {@options.key?(name) ? @options[name] : __send__(settings[:default_method])}
        elsif settings.key?(:default_proc)
          define_method(getter_name) {@options.key?(name) ? @options[name] : settings[:default_proc].call(self)}
        else
          define_method(getter_name) {@options[name]}
        end
      end

      # Difines a write property.
      # @param [Symbol] name the property name
      # @param [Hash] settings settings of the property
      def opt_writer(name, settings = {})
        name = name.to_sym
        setter_name = name.to_s.gsub(/^(.*[^=\?])[=\?]*$/, '\1=')

        convertor =
          case settings[:type]
            when :boolen then proc {|value| not not value}
            when :string then proc {|value| value.to_s}
            when :symbol then proc {|value| value.to_sym}
            when :integer then proc {|value| value.to_i}
            when :float then proc {|value| value.to_f}
            when :length then proc {|value| Length.new(value)}
            when :point then proc {|value| Coordinate.new(value)}
            when :color then proc {|value| Color.new(value)}
            when :font then proc {|value| Font.new(value)}
            else proc {|value| value} if !settings.key?(:map_method) && !settings.key?(:mapper) && !settings.key?(:item_type)
          end

        validator =
          case settings[:type]
          when :symbol
            if settings.key?(:valid_values)
              proc {|value| raise ArgumentError, "\"#{value}\" is invalid value" unless settings[:valid_values].include?(convertor.call(value))}
            end
          when :integer, :float
            if settings.key?(:range)
              proc {|value| raise ArgumentError, "\"#{value}\" is invalid value" unless settings[:range].include?(convertor.call(value))}
            end
          end

        case settings[:type]
        when :hash
          raise ArgumentError, "keys is not specified" unless settings.key?(:keys)
          define_method(setter_name) {|values|
            if values.nil? || values.empty?
              @options.delete(name)
            else
              @options[name] =
                settings[:keys].inject({}) do |hash, key|
                  hash[key] =
                    if convertor
                      convertor.call(values[key])
                    elsif settings.key?(:map_method)
                      __send__(settings[:map_method], values[key])
                    elsif settings.key?(:mapper)
                      settings[:mapper].call(values[key], self)
                    elsif settings.key?(:item_type)
                      case settings[:item_type]
                        when :boolen then not not values[key]
                        when :string then values[key].to_s
                        when :symbol then values[key].to_sym
                        when :integer then values[key].to_i
                        when :float then values[key].to_f
                        when :length then Length.new(values[key])
                        when :point then Coordinate.new(values[key])
                        when :color then value[key].respond_to?(:format) ? value[key] : Color.new(values[key])
                        when :font then Font.new(values[key])
                        else values[key]
                      end
                    end if values[key]
                  hash
                end
            end
            values
          }
        when :array
          define_method(setter_name) {|values|
            if values.nil? || values.empty?
              @options.delete(name)
            else
              @options[name] =
                Array(values).to_a.map {|item|
                  if convertor
                    convertor.call(item)
                  elsif settings.key?(:map_method)
                    __send__(settings[:map_method], item)
                  elsif settings.key?(:mapper)
                    settings[:mapper].call(item, self)
                  elsif settings.key?(:item_type)
                    case settings[:item_type]
                      when :boolen then not not item
                      when :string then item.to_s
                      when :symbol then item.to_sym
                      when :integer then item.to_i
                      when :float then item.to_f
                      when :length then Length.new(item)
                      when :point then Coordinate.new(item)
                      when :color then item.respond_to?(:write_as) ? item : Color.new_or_nil(item)
                      when :font then Font.new(item)
                      else item
                    end
                  else
                    item
                  end
                }
            end
            values
          }
        else
          define_method(setter_name) {|value|
            if value.nil?
              @options.delete(name)
            else
              validator && validator.call(value)
              @options[name] =
                if convertor
                  convertor.call(value)
                elsif settings.key?(:map_method)
                  __send__(settings[:map_method], value)
                elsif ettings.key?(:mapper)
                  settings[:mapper].call(value, self)
                elsif settings.key?(:item_type)
                  case settings[:item_type]
                    when :boolen then not not value
                    when :string then value.to_s
                    when :symbol then value.to_sym
                    when :integer then value.to_i
                    when :float then value.to_f
                    when :length then Length.new(value)
                    when :point then Coordinate.new(value)
                    when :color then Color.new(value)
                    when :font then Font.new(value)
                    else value
                  end
                else
                  value
                end
            end
            value
          }
        end
      end

      # Difines a read-write property.
      # @param [Symbol] name the property name
      # @param [Hash] settings settings of the property
      def opt_accessor(name, settings = {})
        opt_reader(name, settings)
        opt_writer(name, settings)
      end
    end

    # Base class of all the chart classes.
    # @abstract
    # @since 0.0.0
    class Base
      extend OptionCreator

      DEFAULT_CHART_COLOR = ['#ff0f00', '#ff6600', '#ff9e01', '#fcd202', '#f8ff01', '#b0de09', '#04d215', '#0d8ecf', '#0d52d1', '#2a0cd0', '#8a0ccf', '#cd0d74']

      # @private
      attr_reader :options

      # Returns the data for the chart.
      # @return [Chart::ArrayReader] the data for the chart
      attr_reader :data

      # Returns the canvas of the image body.
      # @return [Canvas] the canvas of the image body
      attr_reader :canvas

      # Returns or sets the URI of the background image of the chart. The URL is
      # included the chart image.
      opt_accessor :background_image_url, :type => :string

      # Returns or sets the background image of the chart. The image files is
      # read and included when the chart image is created. The hash includes the
      # following key:
      # [+:path+] (+String+) the file path of the background image file
      # [+:content_type+] (+String+) the content-type of the background image
      #                   file
      opt_accessor :background_image_file, :type => :hash, :default => {}, :keys => [:path, :content_type], :item_type => :string

      # Returns or sets the opacity of the background image of the chart.
      # Default to 1.0.
      opt_accessor :background_image_opacity, :type => :float, :default => 1.0

      # Returns or sets the script string of the chart.
      opt_accessor :script_body, :type => :string

      # Returns or sets the CSS styles of the image body of the chart.
      opt_accessor :css_body, :type => :string

      # Returns or sets the URIs of the script files that the chart includes.
      opt_accessor :script_files, :type => :array, :item_type => :string

      # Returns or sets the URIs of the CSS files that the chart includes.
      opt_accessor :css_files, :type => :array, :item_type => :string

      # Returns or sets the URIs of the XSL files that the chart includes.
      opt_accessor :xsl_files, :type => :array, :item_type => :string

      # Returns or sets the CSS class of the image body of the chart.
      opt_accessor :canvas_css_class, :type => :string

      # Returns or sets whether to output chart's data as metadata in a SVG file.
      # @since 1.2.0
      opt_accessor :output_chart_data, :type => :boolean, :default => false

      # @param [Length] width width of the chart image
      # @param [Length] height height of the chart image
      # @param [Hash{Symbol => Object}] options the options to creat the chart
      #   image. See <em>Instance Attribute</em> of the each chart class
      #   ({Base}, {PieChart}, {LineChart}, etc...).
      def initialize(width, height, options={})
        @canvas = Canvas.new(width, height)
        @options = {}
        options.each do |key, value|
          __send__("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      # Returns width of the chart image on user unit.
      # @return [Length] width of the chart image on user unit
      def width
        @canvas.width
      end

      # Sets width of the chart image on user unit.
      # @param [Length] width width of the chart image on user unit
      def width=(width)
        @canvas.width = width
      end

      # Returns height of the chart image on user unit.
      # @return [Length] height of the chart image on user unit
      def height
        @canvas.height
      end

      # Sets height of the chart image on user unit.
      # @param [Length] height height of the chart image on user unit
      def height=(height)
        @canvas.height = height
      end

      # Sets size of the chart image.
      # @param [Length] width width of the chart image
      # @param [Length] height height of the chart image
      def set_real_size(width, height)
        @canvas.real_width = Length.new(width)
        @canvas.real_height = Length.new(height)
      end

      # Clears <em>real size</em> of the chart image, and sets chart size as
      # values of +width+ and +height+ properties. See {#set_real_size},
      # {#width}, {#height}, {Canvas#real_width} and {Canvas#real_height}.
      def clear_real_size
        @canvas.real_width = nil
        @canvas.real_height = nil
      end

      # Loads the data, and creates chart image.
      # @param [ArrayReader] reader the +ArrayReader+ or its sub class that has
      #   the data of the chart
      def load_data(reader)
        @data = reader
        create_vector_image
      end

      # Save the chart image as a file.
      # @param [String] file_name the file name which is saved the chart image
      #   as
      # @param [Symbol] format the file format. Supports the following formats:
      #   [+:svg+] SVG (Scalable Vector Graphics). If +format+ equals nil,
      #            output SVG format.
      #   [+:eps+] EPS (Encapsulated Post Script).
      #   [+:xaml+] XAML (Extensible Application Markup Language).
      #   [+:emf+] EMF (Enhanced Metafile). Using _IronRuby_ only.
      #   [+:png+] PNG (Portable Network Graphics). _librsvg_ must have been
      #            installed on the system.
      # @option options [Boolean] :inline_mode true if outputs the inlime-mode, false
      #   otherwise. _SVG_ format only.
      def save(file_name, format=nil, options={})
        @canvas.save(file_name, format, options)
      end

      # Outputs the chart image to IO stream.
      # @param [Symbol] format the file format. Supports the following formats:
      #   [+:svg+] SVG (Scalable Vector Graphics). If +format+ equals nil,
      #            output SVG format.
      #   [+:eps+] EPS (Encapsulated Post Script).
      #   [+:xaml+] XAML (Extensible Application Markup Language).
      #   [+:emf+] EMF (Enhanced Metafile). Using _IronRuby_ only.
      #   [+:png+] PNG (Portable Network Graphics). _librsvg_ must have been
      #            installed on the system.
      # @param [IO] io the io which the chart image is outputed to
      # @option options [Boolean] :inline_mode true if outputs the inlime-mode, false
      #   otherwise. _SVG_ format only.
      def puts_in_io(format=nil, io=$>, options={})
        @canvas.puts_in_io(format, io, options)
      end

      # Outputs the chart image as a +String+ (binary).
      # @param [Symbol] format the file format. Supports the following formats:
      #   [+:svg+] SVG (Scalable Vector Graphics). If +format+ equals nil,
      #            output SVG format.
      #   [+:eps+] EPS (Encapsulated Post Script).
      #   [+:xaml+] XAML (Extensible Application Markup Language).
      #   [+:emf+] EMF (Enhanced Metafile). Using _IronRuby_ only.
      #   [+:png+] PNG (Portable Network Graphics). _librsvg_ must have been
      #            installed on the system.
      # @option options [Boolean] :inline_mode true if outputs the inlime-mode, false
      #   otherwise. _SVG_ format only.
      def string(format=nil, options={})
        @canvas.string(format, options)
      end

      private

      def options
        @options
      end

      def chart_color(index)
        if data.has_field?(:color)
          color = Color.new_or_nil(data.records[index].color)
        end
        if color.nil? && respond_to?(:chart_colors) && chart_colors
          color = chart_colors[index]
        end
        color || Color.new(DEFAULT_CHART_COLOR[index % DEFAULT_CHART_COLOR.size])
      end

      # @since 1.0.0
      def create_vector_image
        @canvas.add_css_class(canvas_css_class) if canvas_css_class && !canvas_css_class.empty?
        @canvas.add_script(script_body) if script_body && !script_body.empty?
        @canvas.add_stylesheet(css_body) if css_body && !css_body.empty?
        @canvas.metadata = data if output_chart_data?
        script_files && script_files.each do |script_file|
          @canvas.reference_script_file(script_file)
        end
        css_files && css_files.each do |css_file|
          @canvas.reference_stylesheet_file(css_file)
        end
        xsl_files && xsl_files.each do |xsl_file|
          @canvas.reference_stylesheet_file(xsl_file, 'text/xsl')
        end
        brush = Drawing::Brush.new
        brush.opacity = background_image_opacity if background_image_opacity != 1.0
        if background_image_url
          brush.import_image(canvas, [0, 0], width, height, background_image_url)
        end 
        if background_image_file[:path]
          brush.draw_image(canvas, [0, 0], width, height, background_image_file[:path], :content_type=>background_image_file[:content_type])
        end
      end
    end
  end
end

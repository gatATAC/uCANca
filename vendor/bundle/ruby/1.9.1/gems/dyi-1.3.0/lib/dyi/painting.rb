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

  # +Painting+ is used to specify how the drawing of the interior and the
  # outline of the shape. {Shape::Base} objects (or objects of its subclass)
  # have +painting+ attribute whose value is instance of this class.
  # @since 0.0.0
  class Painting

    # @private
    IMPLEMENT_ATTRIBUTES = [:opacity, :fill, :fill_opacity, :fill_rule,
                            :stroke, :stroke_dasharray, :stroke_dashoffset,
                            :stroke_linecap, :stroke_linejoin, :stroke_miterlimit,
                            :stroke_opacity, :stroke_width,
                            :display, :visibility]
    # @private
    VALID_VALUES = {:fill_rule => ['nonzero','evenodd'],
                    :stroke_linecap => ['butt','round','square'],
                    :stroke_linejoin => ['miter','round','bevel'],
                    :display => ['block','none'],
                    :visibility => ['visible','hidden']}

    # @attribute opacity
    # Returns or sets opacity of the paiting operation. Opacity of Both +stroke+
    # and +fill+ is set at the same time by this attribute.
    # @return [Float] the value of attribute opacity
    # @since 1.0.0
    #+++
    # @attribute fill
    # Returns or sets the interior painting of the shape.
    # @return [Color, #write_as] the value of attribute fill
    #+++
    # @attribute fill_opacity
    # Returns or sets the opacity of the paiting operation used to paint the
    # interior of the shape.
    # @return [Float] the value of attribute fill_opacity
    #+++
    # @attribute fill_rule
    # Returns or sets the rule which is to be used to detemine what parts of the
    # canvas are included inside the shape. specifies one of the following
    # values: <tt>"nonzero"</tt>, <tt>"evenodd"</tt>
    # @return [String] the value of attribute fill_rule
    #+++
    # @attribute stroke
    # Returns or sets the painting along the outline of the shape.
    # @return [Color, #write_as] the value of attribute stroke
    #+++
    # @attribute stroke_dasharray
    # Returns or sets the pattern of dashes and gaps used to stroke paths.
    # @return [Array<Length>] the value of attribute stroke_dasharray
    #+++
    # @attribute stroke_dashoffset
    # Returns or sets the distance into the dash pattern to start the dash.
    # @return [Length] the value of attribute stroke_dashoffset
    #+++
    # @attribute stroke_linecap
    # Returns or sets the shape to be used at the end of open subpaths when they
    # are stroked. specifies one of the following values: <tt>"butt"</tt>,
    # <tt>"round"</tt>, <tt>"square"</tt>
    # @return [String] the value of attribute stroke_linecap
    #+++
    # @attribute stroke_linejoin
    # Returns or sets the shape to be used at the corners of paths or basic
    # shapes when they are stroked. specifies one of the following vlaues:
    # <tt>"miter"</tt>, <tt>"round"</tt>, <tt>"bevel"</tt>
    # @return [String] the value of attribute stroke_linejoin
    #+++
    # @attribute stroke_miterlimit
    # Returns or sets the limit value on the ratio of the miter length to the
    # value of +stroke_width+ attribute. When the ratio exceeds this attribute
    # value, the join is converted from a _miter_ to a _bevel_.
    # @return [Float] the value of attribute stroke_mitterlimit
    #+++
    # @attribute stroke_opacity
    # Returns or sets the opacity of the painting operation used to stroke.
    # @return [Float] the value of attribute stroke_opacity
    #+++
    # @attribute stroke_width
    # Returns or sets the width of the stroke.
    # @return [Length] the value of attribute stroke_width
    #+++
    # @attribute display
    # Returns or sets whether the shape is displayed. specifies one of the
    # following vlaues: <tt>"block"</tt>, <tt>"none"</tt>
    # @return [String] the value of attribute display
    #+++
    # @attribute visibility
    # Returns or sets whether the shape is hidden. specifies one of the
    # following vlaues: <tt>"visible"</tt>, <tt>"hidden"</tt>
    # @return [String] the value of attribute visibility
    attr_reader *IMPLEMENT_ATTRIBUTES

    # Creates and returns a new instace of Paintng. If the argutment is a
    # instance of Painting, returns a copy of the argument.
    # @option options [String] :display the value of attribute {#display display};
    #   one of following values: <tt>"block"</tt>, <tt>"none"</tt>
    # @option options [Color, #write_as] :fill the value of attribute {#fill fill}
    # @option options [#to_f] :fill_opacity the value of attribute fill_opacity
    # @option options [String] :fill_rule the value of attribute {#fill_rule
    #   fill_rule}; one of following values: <tt>"nonzero"</tt>, <tt>"evenodd"</tt>
    # @option options [#to_f] :opacity the value of attribute {#opacity opacity}
    # @option options [Color, #write_as] :stroke the value of attribute {#stroke
    #   stroke}
    # @option options [Array<Length>, String] :stroke_dasharray the value of
    #   attribute {#stroke_dasharray stroke_dasharray}
    # @option options [Length] :stroke_dashoffset the value of attribute
    #   {#stroke_dashoffset stroke_dashoffset}
    # @option options [String] :stroke_linecap the value of attribute
    #   {#stroke_linecap stroke_linecap}; one of following values:
    #   <tt>"butt"</tt>, <tt>"round"</tt>, <tt>"square"</tt>
    # @option options [String] :stroke_linejoin the value of attribute
    #   {#stroke_linejoin stroke_linejoin}; one of following values:
    #   <tt>"miter"</tt>, <tt>"round"</tt>, <tt>"bevel"</tt>
    # @option options [#to_f] :stroke_miterlimit the value of attribute
    #   {#stroke_miterlimit stroke_miterlimit}
    # @option options [#to_f] :stroke_opacity the value of attribute
    #   {#stroke_opacity stroke_opacity}
    # @option options [Length] :stroke_width the value of attribute
    #   {#stroke_width stroke_width}
    # @option options [String] :visible the value of attribute {#visibility
    #   visibility}; one of following values: <tt>"visible"</tt>, <tt>"hidden"</tt>
    def initialize(options={})
      case options
      when Painting
        IMPLEMENT_ATTRIBUTES.each do |attr|
          instance_variable_set("@#{attr}", options.__send__(attr))
        end
      when Hash
        options.each do |attr, value|
          __send__("#{attr}=", value) if IMPLEMENT_ATTRIBUTES.include?(attr.to_sym)
        end
      else
        raise TypeError, "#{options.class} can't be coerced into #{self.class}"
      end
    end

    # @attribute [w] fill_rule
    # @param [String] value the value of attribute fill_rule
    #+++
    # @attribute [w] stroke_linecap
    # @param [String] value the value of attribute stroke_linecap
    #+++
    # @attribute [w] stroke_linejoin
    # @param [String] value the value of attribute stroke_linejoin
    #+++
    # @attribute [w] display
    # @param [String] value the value of attribute display
    #+++
    # @attribute [w] visibility
    # @param [String] value the value of attribute visibility
    VALID_VALUES.each do |attr, valid_values|
      define_method("#{attr.to_s}=") {|value|
        if (value = value.to_s).size == 0
          instance_variable_set("@#{attr}", nil)
        else
          raise ArgumentError, "`#{value}' is invalid #{attr}" unless VALID_VALUES[attr].include?(value)
          instance_variable_set("@#{attr}", value)
        end
      }
    end

    # @attribute
    # @param [Color, #write_as] color the value of attribute fill
    def fill=(color)
      @fill = color.respond_to?(:color?) && color.color? ? color : Color.new_or_nil(color)
    end

    # @attribute
    # @param [Color, #write_as] color the value of attribute stroke
    def stroke=(color)
      @stroke = color.respond_to?(:color?) && color.color? ? color : Color.new_or_nil(color)
    end

    # @attribute
    # @param [Float] opacity the value of attribute opacity
    # @since 1.0.0
    def opacity=(opacity)
      @opacity = opacity.nil? ? nil : opacity.to_f
    end

    # @attribute
    # @param [Float] opacity the value of attribute fill_opacity
    def fill_opacity=(opacity)
      @fill_opacity = opacity.nil? ? nil : opacity.to_f
    end

    # @attribute
    # @param [Float] opacity the value of attribute stroke_opacity
    def stroke_opacity=(opacity)
      @stroke_opacity = opacity.nil? ? nil : opacity.to_f
    end

    # @attribute
    # @param [Length] width the value of attribute stroke_width
    def stroke_width=(width)
      @stroke_width = Length.new_or_nil(width)
    end

    # @attribute
    # @param [Float] miterlimit the value of attribute stroke_miterlimit
    def stroke_miterlimit=(miterlimit)
      @stroke_miterlimit = miterlimit.nil? ? nil : [miterlimit.to_f, 1].max
    end

    # @attribute
    # @param [Array<Legth>, String] array the value of attribute stroke_dasharray
    def stroke_dasharray=(array)
      if (array.nil? || array.empty?)
        @stroke_dasharray = nil
      elsif array.kind_of?(String)
        @stroke_dasharray = array.split(/\s*,\s*/).map {|len| Length.new(len)}
      else
        @stroke_dasharray = array.map {|len| Length.new(len)}
      end
    end

    # @attribute
    # @param [Length] offset the value of attribute stroke_dashoffset
    def stroke_dashoffset=(offset)
      @stroke_dashoffset = Length.new_or_nil(offset)
    end

    # Returns the hash of the attribute values. Even if the return value of this
    # method is modified, the attribute value of the object is not modify.
    # @return [Hash{Symbol => Object}] the copy of the attribute values
    def attributes
      IMPLEMENT_ATTRIBUTES.inject({}) do |hash, attr|
        value = instance_variable_get("@#{attr}")
        unless value.nil?
          hash[attr] = value
        end
        hash
      end
    end

    # Returns whether a value has been set some attribute in this object.
    # @return [Boolean] true if a value has been set some attribute in this
    #   object, false otherwise
    def empty?
      IMPLEMENT_ATTRIBUTES.all? do |attr|
        not instance_variable_get("@#{attr}")
      end
    end

    class << self

      # Returns a new instace of +Painting+ if the argments is not +nil+ (calls
      # +Painting.new+ method), but returns +nil+ if the argument is +nil+.
      # @return [Painting, nil] a new instace of Painting if the argments is not
      #   nil, nil otherwise
      # @see #initialize
      def new_or_nil(*args)
        (args.size == 1 && args.first.nil?) ? nil : new(*args)
      end
    end
  end
end

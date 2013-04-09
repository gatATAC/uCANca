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
# == Overview
#
# This file provides the classes of animation.  The event becomes effective
# only when it is output by SVG format.

#
module DYI

  # @since 1.0.0
  module Animation

    # Base class for animation classes.
    # @abstract
    class Base

      IMPLEMENT_ATTRIBUTES = [:from, :to, :duration, :begin_offset,
                              :begin_event, :end_offset, :end_event, :fill,
                              :additive, :restart, :relays, :relay_times,
                              :calc_mode, :repeat_count, :key_splines]
      VALID_VALUES = {
        :fill => ['freeze','remove'],
        :additive => ['replace', 'sum'],
        :restart => ['always', 'whenNotActive', 'never'],
        :calc_mode => ['discrete', 'linear', 'paced', 'spline']
      }

      # @attribute from
      # Returns a starting value of the animation.
      # @return [Object] a starting value of the animation
      #+++
      # @attribute to
      # Returns a ending value of the animation.
      # @return [Object] a ending value of the animation
      #+++
      # @attribute duration
      # Returns a simple duration of the animation.
      # @return [Numeric] a simple duration of the animation
      #+++
      # @attribute begin_offset
      # Returns a offset that determine the animation begin.
      # @return [Numeric] a offset that determine the animation begin
      #+++
      # @attribute begin_event
      # Returns an event that determine the element begin.
      # @return [Event] an event that determine the element begin
      #+++
      # @attribute end_offset
      # Returns a offset that determine the animation end
      # @return [Numeric] a offset that determine the animation end
      #+++
      # @attribute end_event
      # Returns an event that determine the element end.
      # @return [Event] an event that determine the element end
      #+++
      # @attribute fill
      # Returns the effect of animation when the animation is over, either
      # <tt>'freeze'</tt> or <tt>'remove'</tt>
      # @return [String] the effect of animation
      #+++
      # @attribute additive
      # Returns a value that means whether or not the animation is additive,
      # either <tt>'replace'</tt> or <tt>'sum'</tt>
      # @return [String] either <tt>'replace'</tt> or <tt>'sum'</tt>
      #+++
      # @attribute restart
      # Returns a value for the restart, either <tt>'always'</tt>,
      # <tt>'whenNotActive'</tt> or <tt>'never'</tt>
      # @return [String] either <tt>'always'</tt>, <tt>'whenNotActive'</tt> or
      #   <tt>'never'</tt>
      #+++
      # @attribute relays
      # @return [Array]
      # @since 1.3.0
      #+++
      # @attribute relay_times
      # @return [Array<#to_f>]
      # @since 1.3.0
      #+++
      # @attribute calc_mode
      # @return [String]
      # @since 1.3.0
      #+++
      # @attribute repeat_count
      # @return [Numeric]
      # @since 1.3.0
      #+++
      # @attribute key_splines
      # @return [Array<#to_f>]
      # @since 1.3.0
      attr_reader *IMPLEMENT_ATTRIBUTES

      # Returns whether the animation is cumulative.
      # @return [Boolean] true if the animation is cumulative, false otherwise
      # @since 1.3.0
      def accumulate?
        @accumulate ? true : false
      end

      # @attribute [w] fill
      # @param [String] value the value of attribute fill
      #+++
      # @attribute [w] additive
      # @param [String] value the value of attribute additive
      #+++
      # @attribute [w] restart
      # @param [String] value the value of attribute restart
      #+++
      # @attribute [w] calc_mode
      # @param [String] value the value of attribute calc_mode
      # @since 1.3.0
      VALID_VALUES.each do |attr, valid_values|
        define_method("#{attr.to_s}=") {|value|
          if (value = value.to_s).size == 0
            instance_variable_set("@#{attr}", nil)
          else
            unless VALID_VALUES[attr].include?(value)
              raise ArgumentError, "`#{value}' is invalid #{attr}"
            end
            instance_variable_set("@#{attr}", value)
          end
        }
      end

      def duration=(duration)
        @duration = duration.to_f
      end

      # @attribute [w] repeat_count
      # @param [#to_f] count
      # @since 1.3.0
      def repeat_count=(count)
        @repeat_count = count.to_f
      end

      def begin_offset=(offset)
        @begin_offset = offset.to_f
      end

      def begin_event=(event)
        @begin_event = event
      end

      def end_offset=(offset)
        @end_offset = offset.to_f
      end

      def end_event=(event)
        @end_event = event
      end

      # @attribute [w] relays
      # @param [Array<#to_f>] times
      # @since 1.3.0
      def relay_times=(times)
        @relay_times = times.map{|time| time.to_f}
      end

      # @attribute [w] key_splines
      # @param [Array<#to_f>] keys
      # @since 1.3.0
      def key_splines=(keys)
        @key_splines = keys.map{|time| time.to_f}
      end

      # @param [Boolean] value
      # @since 1.3.0
      def accumulate=(value)
        @accumulate = value
      end

      # @param [Shape::Base] shape a target element for an animation
      # @param [Hash] options an option for an animation
      def initialize(shape, options)
        raise ArgumentError, "`:to' option is required" unless options.key?(:to)
        @shape = shape
        options.each do |attr, value|
          if IMPLEMENT_ATTRIBUTES.include?(attr.to_sym)
            __send__("#{attr}=", value)
          end
        end
        @relays ||= []
        @relay_times ||= []
      end
    end

    # Class representing an animation of a painting
    class PaintingAnimation < Base

      # @attribute [rw] from
      # Returns a starting value of the animation.
      # @return [Painting] a starting value of the animation
      def from=(painting)
        @from = painting && DYI::Painting.new(painting)
      end

      def to=(painting)
        @to = DYI::Painting.new(painting)
      end

      # @attribute relays
      # @return [Array<Painting>]
      # @since 1.3.0
      def relays=(paintings)
        @relays = paintings.map{|painting| DYI::Painting.new(painting)}
      end

      def animation_attributes
        DYI::Painting::IMPLEMENT_ATTRIBUTES.inject({}) do |result, attr|
          from_attr, to_attr = @from && @from.__send__(attr), @to.__send__(attr)
          relay_attrs = @relays.map{|relay| relay.__send__(attr)}
          if to_attr && (from_attr != to_attr || relay_attrs.any?{|relay_attr| from_attr != relay_attrs || relay_attr != to_attr})
            result[attr] = [from_attr].push(*relay_attrs).push(to_attr)
          end
          result
        end
      end

      def write_as(formatter, shape, io=$>)
        formatter.write_painting_animation(self, shape, io,
                                           &(block_given? ? Proc.new : nil))
      end
    end

    # Class representing an animation of transform
    # @attr [Symbol] type a type of transform, either 'translate', 'scale',
    #       'rotate', 'skewX' or 'skewY'
    # @attr [Numeric|Array] from a starting value of the animation
    # @attr [Numeric|Array] to a ending value of the animation
    class TransformAnimation < Base
      IMPLEMENT_ATTRIBUTES = [:type]
      VALID_VALUES = {
        :type => [:translate, :scale, :rotate, :skewX, :skewY]
      }

      attr_reader *IMPLEMENT_ATTRIBUTES

      VALID_VALUES.each do |attr, valid_values|
        define_method("#{attr.to_s}=") {|value|
          if (value = value.to_s).size == 0
            instance_variable_set("@#{attr}", nil)
          else
            unless VALID_VALUES[attr].include?(value)
              raise ArgumentError, "`#{value}' is invalid #{attr}"
            end
            instance_variable_set("@#{attr}", value)
          end
        }
      end

      def from=(value)
        @from =
            case type
            when :translate
              case value
              when Array
                case value.size
                  when 2 then @from = value.map{|v| v.to_f}
                  else raise ArgumentError, "illegal size of Array: #{value.size}"
                end
              when Numeric, Length
                [value.to_f, 0]
              when nil
                nil
              else
                raise TypeError, "illegal argument: #{value}"
              end
            when :scale
              case value
              when Array
                case value.size
                  when 2 then @from = value.map{|v| v.to_f}
                  else raise ArgumentError, "illegal size of Array: #{value.size}"
                end
              when Numeric
                [value.to_f, value.to_f]
              when nil
                nil
              else
                raise TypeError, "illegal argument: #{value}"
              end
            when :rotate
              case value
              when Array
                case value.size
                  when 3 then value.map{|v| v.to_f}
                  else raise ArgumentError, "illegal size of Array: #{value.size}"
                end
              when Numeric
                value.to_f
              when nil
                nil
              else
                raise TypeError, "illegal argument: #{value}"
              end
            when :skewX, :skewY
              value.nil? ? nil : value.to_f
            end
      end

      def to=(value)
        @to =
            case type
            when :translate
              case value
              when Array
                case value.size
                  when 2 then value.map{|v| v.to_f}
                  else raise ArgumentError, "illegal size of Array: #{value.size}"
                end
              when Numeric, Length
                @to = [value.to_f, 0]
              else
                raise TypeError, "illegal argument: #{value}"
              end
            when :scale
              case value
              when Array
                case value.size
                  when 2 then value.map{|v| v.to_f}
                  else raise ArgumentError, "illegal size of Array: #{value.size}"
                end
              when Numeric
                [value.to_f, value.to_f]
              else
                raise TypeError, "illegal argument: #{value}"
              end
            when :rotate
              case value
              when Array
                case value.size
                  when 3 then value.map{|v| v.to_f}
                  else raise ArgumentError, "illegal size of Array: #{value.size}"
                end
              when Numeric
                value.to_f
              else
                raise TypeError, "illegal argument: #{value}"
              end
            when :skewX, :skewY
              value.to_f
            end
      end

      # @attribute relays
      # @return [Array]
      # @since 1.3.0
      def relays=(values)
        @relays =
            case type
            when :translate
              values.map do |value|
                case value
                when Array
                  case value.size
                    when 2 then value.map{|v| v.to_f}
                    else raise ArgumentError, "illegal size of Array: #{value.size}"
                  end
                when Numeric, Length
                  [value.to_f, 0]
                else
                  raise TypeError, "illegal argument: #{value}"
                end
              end
            when :scale
              values.map do |value|
                case value
                when Array
                  case value.size
                    when 2 then value.map{|v| v.to_f}
                    else raise ArgumentError, "illegal size of Array: #{value.size}"
                  end
                when Numeric
                  [value.to_f, value.to_f]
                else
                  raise TypeError, "illegal argument: #{value}"
                end
              end
            when :rotate
              values.map do |value|
                case value
                when Array
                  case value.size
                    when 3 then value.map{|v| v.to_f}
                    else raise ArgumentError, "illegal size of Array: #{value.size}"
                  end
                when Numeric
                  value.to_f
                else
                  raise TypeError, "illegal argument: #{value}"
                end
              end
            when :skewX, :skewY
              values.map{|value| value.to_f}
            end
      end

      def initialize(shape, type, options)
        @type = type
        super(shape, options)
      end

      def write_as(formatter, shape, io=$>)
        formatter.write_transform_animation(self, shape, io,
                                            &(block_given? ? Proc.new : nil))
      end

      class << self
        def translate(shape, options)
          new(shape, :translate, options)
        end

        def scale(shape, options)
          new(shape, :scale, options)
        end

        def rotate(shape, options)
          new(shape, :rotate, options)
        end

        def skew_x(shape, options)
          new(shape, :skewX, options)
        end

        def skew_y(shape, options)
          new(shape, :skewY, options)
        end
      end
    end
  end
end
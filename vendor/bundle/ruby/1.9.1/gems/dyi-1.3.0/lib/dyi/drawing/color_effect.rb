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
  module Drawing

    # @since 0.0.0
    module ColorEffect

      class LinearGradient
        SPREAD_METHODS = ['pad', 'reflect', 'repeat']
        attr_reader :start_point, :stop_point, :spread_method

        def initialize(start_point=[0,0], stop_point=[1,0], spread_method=nil)
          @start_point = start_point
          @stop_point = stop_point
          self.spread_method = spread_method
          @child_elements = []
        end

        def add_color(offset, color)
          @child_elements.push(GradientStop.new(offset, :color => color))
        end

        def add_opacity(offset, opacity)
          @child_elements.push(GradientStop.new(offset, :opacity => opacity))
        end

        def add_color_opacity(offset, color, opacity)
          @child_elements.push(GradientStop.new(offset, :color => color, :opacity => opacity))
        end

        def spread_method=(value)
          raise ArgumentError, "\"#{value}\" is invalid spreadMethod" if value && !SPREAD_METHODS.include?(value)
          @spread_method = value
        end

        def child_elements
          @child_elements.clone
        end

        def color?
          true
        end

        def write_as(formatter, io=$>)
          formatter.write_linear_gradient(self, io)
        end

        class << self

          public

          def simple_gradation(derection, *colors)
            case count = colors.size
            when 0
              nil
            when 1
              Color.new(colors.first)
            else
              case deraction
                when :vertical then obj = new([0,0], [0,1])
                when :horizontal then obj = new([0,0], [1,0])
                when :lowerright then obj = new([0,0], [1,1])
                when :upperright then obj = new([0,1], [1,0])
                else raise ArgumentError, "unknown derection: `#{derection}'"
              end
              colors.each_with_index do |color, i|
                obj.add_color(i.quo(count - 1), color)
              end
              obj
            end
          end
        end
      end

      # Class representing a radial gradient.
      # @since 1.3.0
      class RadialGradient

        # Array of strings that can be indicated as the property spread method.
        SPREAD_METHODS = ['pad', 'reflect', 'repeat']

        # @return [Coordinate] a center point of largest circle for the radial
        #   gradient
        attr_reader :center_point
        # @return [Length] a radius of largest circle for the radial gradient
        attr_reader :radius
        # @return [Coordinate] a focal point of largest circle for the radial
        #   gradient
        attr_reader :focal_point
        # @return [String] a string that mean what happens if the gradient
        #   starts or ends inside the bounds of the objects being painted by the
        #   gradient
        attr_reader :spread_method

        # @param [Array<Numeric>] center_point a relative position of the center
        #   point to the shape that is drawn
        # @param [Numeric] radius a relative length of largest circle for the
        #   radial gradient to the shape that is drawn
        # @param [Array<Numeric>] focal_point a relative position of the focal
        #   point of largest circle for the radial gradient to the shape that is
        #   drawn. If this paramater is nil, this paramater is considered to
        #   indicate the same value as center_point
        # @param [String] spread_method a string that mean what happens if the
        #   gradient starts or ends inside the bounds of the objects being
        #   painted by the gradient
        def initialize(center_point, radius, focal_point=nil, spread_method=nil)
          @center_point = Coordinate.new(center_point)
          @radius = Length.new(radius)
          @focal_point = focal_point ? Coordinate.new(focal_point) : @center_point
          self.spread_method = spread_method
          @child_elements = []
        end

        # Adds a color to the gradient.
        # @param [Numeirc] offset a ratio of distance from focal point to the
        #   edge of the largest circle
        # @param [Color] color a color at the offset point
        def add_color(offset, color)
          @child_elements.push(GradientStop.new(offset, :color => color))
        end

        # Adds a opacity to the gradient.
        # @param [Numeirc] offset a ratio of distance from focal point to the
        #   edge of the largest circle
        # @param [Numeric] opacity a opecity at the offset point
        def add_opacity(offset, opacity)
          @child_elements.push(GradientStop.new(offset, :opacity => opacity))
        end

        # Adds a color and a opacity to the gradient.
        # @param [Numeirc] offset a ratio of distance from focal point to the
        #   edge of the largest circle
        # @param [Color] color a color at the offset point
        # @param [Numeric] opacity a opecity at the offset point
        def add_color_opacity(offset, color, opacity)
          @child_elements.push(GradientStop.new(offset, :color => color, :opacity => opacity))
        end

        # Sets value to the spread method property.
        # @param [String] spread_method a string that mean what happens if the
        #   gradient starts or ends inside the bounds of the objects being
        #   painted by the gradient
        def spread_method=(value)
          raise ArgumentError, "\"#{value}\" is invalid spreadMethod" if value && !SPREAD_METHODS.include?(value)
          @spread_method = value
        end

        # Returns the array of the gradient colors.
        # @return [Array<GradientStop>] the array of the gradient colors
        def child_elements
          @child_elements.clone
        end

        # Returns whether this object is a color.
        # @return [Boolean] always false
        def color?
          true
        end

        # Writes the gradient on io object.
        # @param [Formatter::Base] formatter an object that defines the image
        #   format
        # @param [IO] io an io to be written
        def write_as(formatter, io=$>)
          formatter.write_radial_gradient(self, io)
        end

        class << self

          public

          # Create a gradient on which spaced the specified colors.
          # @param [Color] colors a color that the gradient uses
          # @return [RadialGradient] a gradient on which spaced the colors
          def simple_gradation(*colors)
            case count = colors.size
            when 0
              nil
            when 1
              Color.new(colors.first)
            else
              obj = new(['50%','50%'], '50%', ['50%','50%'])
              colors.each_with_index do |color, i|
                obj.add_color(i.quo(count - 1), color)
              end
              obj
            end
          end
        end
      end

      class GradientStop
        attr_reader :offset, :color, :opacity

        def initialize(offset, options={})
          @offset = offset.to_f
          self.color = options[:color]
          self.opacity = options[:opacity]
        end

        def color=(value)
          @color = Color.new_or_nil(value)
          value
        end

        def opacity=(value)
          @opacity = value ? value.to_f : nil
          value
        end

        def write_as(formatter, io=$>)
          formatter.write_gradient_stop(self, io)
        end
      end
    end
  end
end

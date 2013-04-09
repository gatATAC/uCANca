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
  module Shape
    # Marker object represents a symbol at One or more vertices of the lines.
    #
    # Marker provides some pre-defined shapes and a custom marker defined freely.
    # @since 1.3.0
    class ReusedShape < Base

      attr_reader :source_element

      # Returns width of the re-used shape.
      attr_length :width

      # Returns heigth of the re-used shape.
      attr_length :height

      def initialize(source_element, left_top, options={})
        @source_element = source_element.to_reused_source
        width = Length.new_or_nil(options.delete(:width))
        height = Length.new_or_nil(options.delete(:height))
        @lt_pt = Coordinate.new(left_top)
        @lt_pt += Coordinate.new(width, 0) if width && width < Length::ZERO
        @lt_pt += Coordinate.new(0, height) if height && height < Length::ZERO
        @width = width && width.abs
        @height = height && height.abs
        @attributes = init_attributes(options)
        source_element.publish_id
      end

      # Returns a x-axis coordinate of the left side of the re-used shape.
      # @return [Length] the x-axis coordinate of the left side
      def left
        @lt_pt.x
      end

      # Returns a x-axis coordinate of the right side of the re-used shape.
      # @return [Length] the x-axis coordinate of the right side
      def right
        width && (@lt_pt.x + width)
      end

      # Returns a y-axis coordinate of the top of the re-used shape.
      # @return [Length] a y-axis coordinate of the top
      def top
        @lt_pt.y
      end

      # Returns a y-axis coordinate of the bottom of the re-used shape.
      # @return [Length] a y-axis coordinate of the bottom
      def bottom
        height && (@lt_pt.y + height)
      end

      # Returns a coordinate of the center of the re-used shape.
      # @return [Coordinate] a coordinate of the center
      def center
        width && height && (@lt_pt + Coordinate.new(width.quo(2), height.quo(2)))
      end

      def child_elements
        source_element.child_elements
      end

      # @return [Boolean] whether the element has a URI reference
      def has_uri_reference?
        true
      end

      # Writes image on io object.
      # @param [Formatter::Base] formatter an object that defines the image format
      # @param [IO] io an io to be written
      def write_as(formatter, io=$>)
        formatter.write_reused_shape(self, io)
      end
    end
  end
end

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

    # The body of Vector-Image. This class is a container for all graphical
    # elements that make up the image.
    # @since 1.3.0
    class GraphicalTemplate < Base

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

      # Returns a metadata object that the image has.
      # @return [Object] a metadata object that the image has.
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
                     preserve_aspect_ratio='none', options={})
        self.width = width
        self.height = height
        @view_box = "0 0 #{width} #{height}"
        @preserve_aspect_ratio = preserve_aspect_ratio
        @child_elements = []
        self.css_class = options[:css_class]
      end

      # Returns whether this instance is root element of the shape.
      # @return [Boolean] always true.
      def root_element?
        false
      end

      # Writes image on io object.
      # @param [Formatter::Base] formatter an object that defines the image format
      # @param [IO] io an io to be written
      def write_as(formatter, io=$>)
        formatter.write_template(self, io)
      end

      def instantiate_on(parent, left_top, options={})
        Shape::ReusedShape.new(self, left_top, options).draw_on(parent)
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
    end
  end
end

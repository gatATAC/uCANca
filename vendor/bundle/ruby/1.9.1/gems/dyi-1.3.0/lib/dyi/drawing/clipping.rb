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
    class Clipping < Element
      RULES = ['nonzero', 'evenodd']
      attr_reader :rule, :shapes

      # @since 1.0.0
      attr_reader :canvas

      def initialize(*shapes)
        @shapes = shapes
        @rules = Array.new(shapes.size)
      end

      # @since 1.0.0
      def child_elements
        @shapes
      end

      # @since 1.0.0
      def set_canvas(canvas)
        if @canvas.nil?
          @canvas = canvas
        elsif @canvas != canvas
          raise Arguments, "the clipping is registered to another canvas"
        end
      end

      def add_shape(shape, rule=nil)
        raise ArgumentError, "\"#{rule}\" is invalid rule" if rule && !RULES.include?(rule)
        unless @shapes.include?(shape)
          @shapes.push(shape)
          @rules.push(rule)
        end
      end

      def remove_shape(shape)
        index = @shapes.each_with_index {|s, i| break i if s == shape}
        if index
          @shapes.delete_at(index)
          @rules.delete_at(index)
        end
      end

      def each_shapes #:yields: shape, rule
        @shapes.size.times do |i|
          yield @shapes[i], @rules[i]
        end
      end

      def write_as(formatter, io=$>)
        formatter.write_clipping(self, io)
      end
    end
  end
end

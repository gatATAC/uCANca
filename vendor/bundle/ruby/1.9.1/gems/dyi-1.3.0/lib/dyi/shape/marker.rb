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
    # @since 1.2.0
    class Marker < Element

      attr_accessor :view_box, :ref_point, :marker_units, :width, :height, :orient, :shapes, :canvas

      @@predefined_markers = {
          :circle => {
            :view_box => "-1 -1 2 2",
            :magnify => 1.0,
            :creator => proc{|painting, direction|
              Shape::Circle.new([0, 0], 1, :painting => painting)
            }},
          :triangle => {
            :view_box => "-1 -1 2 2",
            :magnify => 1.1954339629,
            :creator => proc{|painting, direction|
              case direction
              when :to_end
                shape = Shape::Polygon.new([1, 0], :painting => painting)
                shape.line_to([-0.5, 0.8660254038], [-0.5, -0.8660254038])
              when :to_start
                shape = Shape::Polygon.new([-1, 0], :painting => painting)
                shape.line_to([0.5, -0.8660254038], [0.5, 0.8660254038])
              else
                shape = Shape::Polygon.new([0, -1], :painting => painting)
                shape.line_to([0.8660254038, 0.5], [-0.8660254038, 0.5])
              end
              shape
            }},
          :square => {
            :view_box => "-1 -1 2 2",
            :magnify => 0.8862269255,
            :creator => proc{|painting, direction|
              Shape::Rectangle.new([-1, -1], 2, 2, :painting => painting)
            }},
          :rhombus => {
            :view_box => "-1 -1 2 2",
            :magnify => 1.2533141373,
            :creator => proc{|painting, direction|
              shape = Shape::Polygon.new([1, 0], :painting => painting)
              shape.line_to([0, 1], [-1, 0], [0, -1])
              shape
            }},
          :pentagon => {
            :view_box => "-1 -1 2 2",
            :magnify => 1.1494809262,
            :creator => proc{|painting, direction|
              case direction
              when :to_end
                shape = Shape::Polygon.new([1, 0], :painting => painting)
                shape.line_to([0.3090169944, 0.9510565163],
                              [-0.8090169944, 0.5877852523],
                              [-0.8090169944, -0.5877852523],
                              [0.3090169944, -0.9510565163])
              when :to_start
                shape = Shape::Polygon.new([-1, 0], :painting => painting)
                shape.line_to([-0.3090169944, -0.9510565163],
                              [0.8090169944, -0.5877852523],
                              [0.8090169944, 0.5877852523],
                              [-0.3090169944, 0.9510565163])
              else
                shape = Shape::Polygon.new([0, -1], :painting => painting)
                shape.line_to([0.9510565163, -0.3090169944],
                              [0.5877852523, 0.8090169944],
                              [-0.5877852523, 0.8090169944],
                              [-0.9510565163, -0.3090169944])
              end
              shape
            }},
          :hexagon => {
            :view_box => "-1 -1 2 2",
            :magnify => 1.0996361108,
            :creator => proc{|painting, direction|
              case direction
              when :to_end, :to_start
                shape = Shape::Polygon.new([1, 0], :painting => painting)
                shape.line_to([0.5, 0.8660254038],
                              [-0.5, 0.8660254038],
                              [-1, 0],
                              [-0.5, -0.8660254038],
                              [0.5, -0.8660254038])
              else
                shape = Shape::Polygon.new([0, -1], :painting => painting)
                shape.line_to([0.8660254038, -0.5],
                              [0.8660254038, 0.5],
                              [0, 1],
                              [-0.8660254038, 0.5],
                              [-0.8660254038, -0.5])
              end
              shape
            }}}
=begin
      @@predefined_arrows = {
          :triangle => {
            :view_box => {:to_end => "0 -3 8 6", :to_start => "-8 -3 8 6"},
            :magnify => {:width => 4.0 / 3.0, :height => 1.0},
            :creator => proc{|painting, direction|
              if direction == :to_start
                shape = Shape::Polygon.new([-8, 0], :painting => painting)
                shape.line_to([0, -3], [0, 3])
              else
                shape = Shape::Polygon.new([8, 0], :painting => painting)
                shape.line_to([0, -3], [0, 3])
              end
              shape
            },
            :ref_point_getter => proc{|size, direction|
              Coordinate.new(direction == :to_start ? (1 - size) : (size - 1), 0)
            }},
          :open => {
            :view_box => {:to_end => "0 -3 8 6", :to_start => "-8 -3 8 6"},
            :magnify => {:width => 4.0 / 3.0, :height => 1.0},
            :creator => proc{|painting, direction|
              if direction == :to_start
                shape = Shape::Polygon.new([-8, 0], :painting => painting)
                shape.line_to([0, -3], [0, 3])
              else
                shape = Shape::Polygon.new([8, 0], :painting => painting)
                shape.line_to([0, -3], [0, 3])
              end
              shape
            },
            :ref_point_getter => proc{|size, direction|
              Coordinate.new(direction == :to_start ? (1 - size) : (size - 1), 0)
            }},
          :stealth => {
            :view_box => {:to_end => "0 -3 8 6", :to_start => "-8 -3 8 6"},
            :magnify => {:width => 4.0 / 3.0, :height => 1.0},
            :creator => proc{|painting, direction|
              if direction == :to_start
                shape = Shape::Polygon.new([-8, 0], :painting => painting)
                shape.line_to([0, -3], [-1, -0.5], [-1, 0.5], [0, 3])
              else
                shape = Shape::Polygon.new([8, 0], :painting => painting)
                shape.line_to([0, -3], [1, -0.5], [1, 0.5], [0, 3])
              end
              shape
            },
            :ref_point_getter => proc{|size, direction|
              Coordinate.new(direction == :to_start ? (1 - size) : (size - 1), 0)
            }}}
=end

      # @overload initialize(marker_type, options = {})
      #   Creates a new pre-defined marker.
      #   @param [Symbol] marker_type a type of the marker. Specifies the
      #     following: +:circle+, +:triangle+, +:inverted_triangle+, +:square+,
      #     +:rhombus+, +:inverted_pentagon+, +:hexagon+
      #   @option options [Number] :size size of the marker. Specifies the
      #     relative size to line width
      #   @option options [Painting] :painting painting of the marker
      #   @option options [Number, "auto"] :orient how the marker is rotated.
      #     Specifies a rotated angle or <tt>"auto"</tt>. <tt>"auto"</tt> means
      #     the marker rotate the orientation of the line
      #   @option options [Symbol] :direction a direction of the marker. This
      #     option is valid if option +:orient+ value is <tt>"auto"</tt>.
      #     Specifies the following: +:to_start+, +:to_end+
      # @overload initialize(shapes, options = {})
      #   Creates a new custom marker.
      #   @param [Shape::Base, Array<Shape::Base>] shapes a shape that represents
      #     marker
      #   @option options [String] :units a setting to define the coordinate
      #     system of the custom marker.
      #   @option options [String] :view_box
      #   @option options [Coordinate] :ref_point
      #   @option options [Length] :width
      #   @option options [Length] :height
      #   @option options [Number, nil] :orient
      # @raise [ArgumentError]
      def initialize(shape, options={})
        case shape
        when Symbol
          inverted = !!(shape.to_s =~ /^inverted_/)
          marker_source = @@predefined_markers[inverted ? $'.to_sym : shape]
          raise ArgumentError, "`#{shape}' is unknown marker" unless marker_source
          @ref_point = Coordinate::ZERO
          if options[:orient] == 'auto'
            direction = (inverted ^ (options[:direction] == :to_start)) ? :to_start : :to_end
            @orient = 'auto'
          else
            direction = nil
            @orient = (options[:orient] || 0) + (inverted ? 180 : 0)
          end
          @shapes = [marker_source[:creator].call(options[:painting] || {}, direction)]
          @view_box = marker_source[:view_box]
          @marker_units = 'strokeWidth'
          @width = @height = Length.new(options[:size] || 3) * marker_source[:magnify]
        when Shape::Base, Array
          @ref_point = options[:ref_point] || Coordinate::ZERO
          @shapes = shape.is_a?(Shape::Base) ? [shape] : shape
          @view_box = options[:view_box] || "0 0 3 3"
          @marker_units = options[:units] || 'strokeWidth'
          @width = Length.new(options[:width] || 3)
          @height = Length.new(options[:height] || 3)
          @orient = options[:orient]
        else
          raise ArgumentError, "argument is a wrong class"
        end
      end

      def set_canvas(canvas)
        if @canvas.nil?
          @canvas = canvas
        elsif @canvas != canvas
          raise Arguments, "the clipping is registered to another canvas"
        end
      end

      def child_elements
        @shapes
      end

      def write_as(formatter, io=$>)
        formatter.write_marker(self, io)
      end

      class << self
=begin
        # @overload new_arrow(options = {})
        #   Creates a new pre-defined triangle-arrow-marker.
        #   @option options [Number] :size size of the marker. Specifies the
        #     relative size to line width
        #   @option options [Painting] :painting painting of the marker
        #   @option options [Symbol] :direction a direction of the marker.
        #     Specifies the following: +:to_start+, +:to_end+
        # @overload new_arrow(arrow_type, options = {})
        #   Creates a new pre-defined arrow-marker.
        #   @param [Symbol] arrow_type a type of the arrow-marker. Specifies the
        #     following: +:triangle+, +:open+, +:stealth+
        #   @option options [Number] :size size of the marker. Specifies the
        #     relative size to line width
        #   @option options [Painting] :painting painting of the marker
        #   @option options [Symbol] :direction a direction of the marker.
        #     Specifies the following: +:to_start+, +:to_end+
        # @raise [ArgumentError]
        def new_arrow(*args)
          arrow_type = :triangle
          options = {}
          case args.first
          when Symbol
            raise ArgumentError, "wrong number of arguments (#{args.size} for 2)" if 2 < args.size
            arrow_type = args.first
            if args.size == 2
              options = args[1]
            end
          when nil
            raise ArgumentError, "arrow_type is nil" if args.size != 0
          else
            raise ArgumentError, "wrong number of arguments (#{args.size} for 1)" if args.size != 1
            arrow_type = :triangle
            options = args.first
          end

          marker_source = @@predefined_arrows[arrow_type]
          direction = options[:direction] == :to_start ? :to_start : :to_end
          size = options[:size] || 3
          raise ArgumentError, "option `size' must be greater than 1" if size < 1
          new(marker_source[:creator].call(options[:painting] || {}, direction),
              :ref_point => marker_source[:ref_point_getter].call(size, direction),
              :view_box => marker_source[:view_box][direction],
              :width => Length.new(marker_source[:magnify][:width]) * size,
              :height => Length.new(marker_source[:magnify][:height]) * size,
              :orient => 'auto')
        end
=end
      end
    end
  end
end

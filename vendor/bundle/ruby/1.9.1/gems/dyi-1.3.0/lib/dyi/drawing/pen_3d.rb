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
    class CubicPen < Pen
      POSITION_TYPE_VALUES = [:baseline, :center, :backline]
      attr_reader :position_type, :background_color, :background_opacity, :dx, :dy

      def initialize(options={})
        self.position_type = options.delete(:position_type)
        self.background_color = options.delete(:background_color)
        self.background_opacity = options.delete(:background_opacity)
        self.dx = options.delete(:dx)
        self.dy = options.delete(:dy)
        super
      end

      def position_type=(value)
        if value.to_s.size != 0
          raise ArgumentError, "\"#{value}\" is invalid position-type" unless POSITION_TYPE_VALUES.include?(value)
          @position_type = value
        else
          @position_type = nil
        end
      end

      def background_color=(color)
        @background_color = Color.new_or_nil(color)
      end

      def background_opacity=(opacity)
        @background_opacity = opacity ? opacity.to_f : nil
      end

      def dx
        @dx || Length.new(24)
      end

      def dx=(value)
        @dx = Length.new_or_nil(value)
      end

      def dy
        @dy || Length.new(-8)
      end

      def dy=(value)
        @dy = Length.new_or_nil(value)
      end

      def brush
        @brush ||= Brush.new(:color => background_color || color, :opacity => background_opacity || nil)
      end

      def draw_line(canvas, start_point, end_point, options={})
        group = Shape::ShapeGroup.new
        draw_background_shape(group, start_point, end_point, options)
        super(group, start_point, end_point, options)
        adjust_z_coordinate(group)
        group.draw_on(canvas)
      end

      def draw_polyline(canvas, point, options={}, &block)
        group = Shape::ShapeGroup.new(options)
        polyline = super(group, point, {}, &block)
        (1...polyline.points.size).each do |i|
          draw_background_shape(group, polyline.points[i-1], polyline.points[i], {})
        end
        polyline = super(group, point, {}, &block)
        adjust_z_coordinate(group)
        group.draw_on(canvas)
      end

      private

      def adjust_z_coordinate(shape)
        case position_type
          when :center then shape.translate(-dx / 2, -dy / 2)
          when :backline then shape.translate(-dx, -dy)
        end
      end

      def draw_background_shape(canvas, start_point, end_point, options={})
        brush.draw_polygon(canvas, start_point, options) {|polygon|
          polygon.line_to(end_point)
          polygon.line_to(Coordinate.new(end_point) + Coordinate.new(dx, dy))
          polygon.line_to(Coordinate.new(start_point) + Coordinate.new(dx, dy))
        }
      end
    end

    # @since 0.0.0
    class CylinderBrush < Brush

      # @since 1.1.0
      def initialize(options={})
        self.ry = options.delete(:ry)
        super
      end

      def ry
        @ry || Length.new(8)
      end

      def ry=(value)
        @ry = Length.new_or_nil(value)
      end

      def fill
        @painting.fill
      end

      def fill=(value)
        if @painting.fill != Color.new_or_nil(value)
          @painting.fill = Color.new_or_nil(value)
        end
        value
      end

      alias color fill
      alias color= fill=

      def draw_rectangle(canvas, left_top_point, width, height, options={})
        radius_x = width.quo(2)
        radius_y = ry

        shape = Shape::ShapeGroup.draw_on(canvas)
        top_painting = @painting.clone
        top_painting.fill = top_color
        Shape::Ellipse.create_on_center_radius(Coordinate.new(left_top_point) + [width.quo(2), 0], radius_x, radius_y, merge_option(:painting => top_painting)).draw_on(shape)
        body_painting = @painting.clone
        body_painting.fill = body_gradient(canvas)
        Shape::Path.draw(left_top_point, merge_option(:painting => body_painting)) {|path|
          path.rarc_to([width, 0], radius_x, radius_y, 0, false, false)
          path.rline_to([0, height])
          path.rarc_to([-width, 0], radius_x, radius_y, 0, false, true)
          path.rline_to([0, -height])
        }.draw_on(shape)
        shape
      end

      private

      def body_gradient(canvas)
        gradient = ColorEffect::LinearGradient.new([0,0],[1,0])
        gradient.add_color(0, color.merge(Color.white, 0.4))
        gradient.add_color(0.3, color.merge(Color.white, 0.65))
        gradient.add_color(0.4, color.merge(Color.white, 0.7))
        gradient.add_color(0.5, color.merge(Color.white, 0.65))
        gradient.add_color(0.7, color.merge(Color.white, 0.4))
        gradient.add_color(1, color)
        gradient
      end

      def top_color
        color.merge(Color.white, 0.3)
      end
    end

    # @since 0.0.0
    class ColumnBrush < Brush

      # @since 1.1.0
      def initialize(options={})
        self.flank_color = options.delete(:flank_color)
        self.dy = options.delete(:dy)
        super
      end

      def dy
        @dy || Length.new(16)
      end

      def dy=(value)
        @dy = Length.new_or_nil(value)
      end

      # Returns a flank color
      # @since 1.1.0
      def flank_color
        @flank_color || color.merge('black', 0.2)
      end

      # Set a flank color
      # @since 1.1.0
      def flank_color=(color)
        @flank_color = Color.new_or_nil(color)
      end

      # Draw a cylinder by specifying the upper surface, which is a circle
      # @since 1.1.0
      def draw_circle(canvas, center_point, radius, options={})
        radius = Length.new(radius).abs
        center_point = Coordinate.new(center_point)
        group_options = {}
        parts_options = merge_option(options)
        (flank_painting = @painting.dup).fill = flank_color
        flank_options = parts_options.merge(:painting => flank_painting)
        [:anchor_href, :anchor_target, :css_class, :id].each do |key|
          group_options[key] = parts_options.delete(key)
        end
        shape = Shape::ShapeGroup.draw_on(canvas, group_options)
        super(shape, center_point + [0, dy], radius, parts_options)
        draw_closed_path(shape, center_point - [radius, 0], flank_options) {|path|
          path.rarc_to([radius * 2, 0], radius, radius)
          path.rline_to([0, dy])
          path.rarc_to([- radius * 2, 0], radius, radius, 0, false, false)
        }
        draw_closed_path(shape, center_point - [radius, 0], flank_options) {|path|
          path.rarc_to([radius * 2, 0], radius, radius, 0, false, false)
          path.rline_to([0, dy])
          path.rarc_to([- radius * 2, 0], radius, radius)
        }
        super(shape, center_point, radius, parts_options)
        shape
      end

      # Draw a cylinder by specifying the upper surface, which is a ellipse
      # @since 1.1.0
      def draw_ellipse(canvas, center_point, radius_x, radius_y, options={})
        radius_x, radius_y = Length.new(radius_x).abs, Length.new(radius_y).abs
        center_point = Coordinate.new(center_point)
        group_options = {}
        parts_options = merge_option(options)
        (flank_painting = @painting.dup).fill = flank_color
        flank_options = parts_options.merge(:painting => flank_painting)
        [:anchor_href, :anchor_target, :css_class, :id].each do |key|
          group_options[key] = parts_options.delete(key)
        end
        shape = Shape::ShapeGroup.draw_on(canvas, group_options)
        super(shape, center_point + [0, dy], radius_x, radius_y, parts_options)
        draw_closed_path(shape, center_point - [radius_x, 0], flank_options) {|path|
          path.rarc_to([radius_x * 2, 0], radius_x, radius_y)
          path.rline_to([0, dy])
          path.rarc_to([- radius_x * 2, 0], radius_x, radius_y, 0, false, false)
        }
        draw_closed_path(shape, center_point - [radius_x, 0], flank_options) {|path|
          path.rarc_to([radius_x * 2, 0], radius_x, radius_y, 0, false, false)
          path.rline_to([0, dy])
          path.rarc_to([- radius_x * 2, 0], radius_x, radius_y)
        }
        super(shape, center_point, radius_x, radius_y, parts_options)
        shape
      end

      # @since 1.1.0
      def draw_toroid(canvas, center_point, radius_x, radius_y, inner_radius, options={})
        if inner_radius >= 1 || 0 > inner_radius
          raise ArgumentError, "inner_radius option is out of range: #{inner_radius}"
        end
        radius_x, radius_y = Length.new(radius_x).abs, Length.new(radius_y).abs
        center_point = Coordinate.new(center_point)
        arc_right_pt = center_point + [radius_x, 0]
        arc_left_pt = center_point - [radius_x , 0]
        inner_radius_x = radius_x * inner_radius
        inner_radius_y = radius_y * inner_radius
        inner_arc_right_pt = center_point + [inner_radius_x , 0]
        inner_arc_left_pt = center_point - [inner_radius_x, 0]
        group_options = {}
        parts_options = merge_option(options)
        (flank_painting = @painting.dup).fill = flank_color
        flank_options = parts_options.merge(:painting => flank_painting)
        [:anchor_href, :anchor_target, :css_class, :id].each do |key|
          group_options[key] = parts_options.delete(key)
        end
        shape = Shape::ShapeGroup.draw_on(canvas, group_options)

        super(shape, center_point + [0, dy], radius_x, radius_y, inner_radius, parts_options)
        draw_sector_back_flank(shape, center_point,
                               radius_x, radius_y,
                               arc_left_pt, arc_right_pt,
                               180, 180, flank_options)
        draw_sector_back_flank(shape, center_point,
                               inner_radius_x, inner_radius_y,
                               inner_arc_left_pt, inner_arc_right_pt,
                               180, 180, flank_options)
        draw_sector_front_flank(shape, center_point,
                                inner_radius_x, inner_radius_y,
                                inner_arc_right_pt, inner_arc_left_pt,
                                0, 180, flank_options)
        draw_sector_front_flank(shape, center_point,
                                radius_x, radius_y,
                                arc_right_pt, arc_left_pt,
                                0, 180, flank_options)
        super(shape, center_point, radius_x, radius_y, inner_radius, parts_options)
      end

      private

      # @since 1.1.0
      def draw_sector_internal(canvas, center_point,
                               radius_x, radius_y, inner_radius,
                               arc_start_pt, arc_end_pt,
                               start_angle, center_angle, merged_options)
        if inner_radius == 0
          inner_arc_start_pt = inner_arc_end_pt = center_point
        else
          inner_arc_start_pt = center_point * (1 - inner_radius) + arc_end_pt * inner_radius
          inner_arc_end_pt = center_point * (1 - inner_radius) + arc_start_pt * inner_radius
          inner_radius_x = radius_x * inner_radius
          inner_radius_y = radius_y * inner_radius
        end
        group_options = {}
        parts_options = merged_options.dup
        (flank_painting = @painting.dup).fill = flank_color
        flank_options = parts_options.merge(:painting => flank_painting)
        [:anchor_href, :anchor_target, :css_class, :id].each do |key|
          group_options[key] = parts_options.delete(key)
        end
        shape = Shape::ShapeGroup.draw_on(canvas, group_options)

        super(shape, center_point + [0, dy],
              radius_x, radius_y, inner_radius,
              arc_start_pt + [0, dy], arc_end_pt + [0, dy],
              start_angle, center_angle, parts_options)

        draw_sector_back_flank(shape, center_point,
                               radius_x, radius_y,
                               arc_start_pt, arc_end_pt,
                               start_angle, center_angle, flank_options)

        if center_angle == 180 && inner_radius == 0
          draw_polygon(shape, arc_start_pt, flank_options) {|polygon|
            polygon.line_to(arc_start_pt + [0, dy], arc_end_pt + [0, dy], arc_end_pt)
          }
        else
          pt_ys = [[arc_start_pt.y, proc {
                        draw_polygon(shape, inner_arc_end_pt, flank_options) {|polygon|
                          polygon.line_to(inner_arc_end_pt + [0, dy], arc_start_pt + [0, dy], arc_start_pt)
                        }
                      }],
                   [arc_end_pt.y, proc {
                        draw_polygon(shape, inner_arc_start_pt, flank_options) {|polygon|
                          polygon.line_to(inner_arc_start_pt + [0, dy], arc_end_pt + [0, dy], arc_end_pt)
                        }
                      }],
                   [center_point.y, proc {
                        if inner_radius != 0
                          draw_sector_back_flank(shape, center_point,
                                                 inner_radius_x, inner_radius_y,
                                                 inner_arc_end_pt, inner_arc_start_pt,
                                                 start_angle, center_angle, flank_options)
                          draw_sector_front_flank(shape, center_point,
                                                  inner_radius_x, inner_radius_y,
                                                  inner_arc_end_pt, inner_arc_start_pt,
                                                  start_angle, center_angle, flank_options)
                        end
                      }]]

          pt_ys.sort{|a,b| a[0] <=> b[0]}.each do |pt_y|
            pt_y[1].call
          end
        end

        draw_sector_front_flank(shape, center_point,
                                radius_x, radius_y,
                                arc_start_pt, arc_end_pt,
                                start_angle, center_angle, flank_options)

        super(shape, center_point,
              radius_x, radius_y, inner_radius,
              arc_start_pt, arc_end_pt,
              start_angle, center_angle, parts_options)
        shape
      end

      # @since 1.1.0
      def draw_sector_back_flank(canvas, center_point,
                                 radius_x, radius_y,
                                 arc_start_pt, arc_end_pt,
                                 start_angle, center_angle, options)
        if start_angle < 180
          if 360 < start_angle + center_angle
            draw_closed_path(canvas, center_point - [radius_x, 0], options) {|path|
              path.rarc_to([radius_x * 2, 0], radius_x, radius_y)
              path.rline_to([0, dy])
              path.rarc_to([- radius_x * 2, 0], radius_x, radius_y, 0, false, false)
            }
          elsif 180 < start_angle + center_angle
            draw_closed_path(canvas, center_point - [radius_x, 0], options) {|path|
              path.arc_to(arc_end_pt, radius_x, radius_y)
              path.rline_to([0, dy])
              path.arc_to(center_point + [-radius_x, dy], radius_x, radius_y, 0, false, false)
            }
          end
        elsif 360 < start_angle + center_angle
          draw_closed_path(canvas, arc_start_pt, options) {|path|
            path.arc_to(center_point + [radius_x, 0], radius_x, radius_y)
            path.rline_to([0, dy])
            path.arc_to(arc_start_pt + [0, dy], radius_x, radius_y, 0, false, false)
            if 540 < start_angle + center_angle
              path.close_path
              path.move_to(center_point - [radius_x, 0])
              path.arc_to(arc_end_pt, radius_x, radius_y)
              path.rline_to([0, dy])
              path.arc_to(center_point + [-radius_x, dy], radius_x, radius_y, 0, false, false)
            end
          }
        else
          draw_closed_path(canvas, arc_start_pt, options) {|path|
            path.arc_to(arc_end_pt, radius_x, radius_y)
            path.rline_to([0, dy])
            path.arc_to(arc_start_pt + [0, dy], radius_x, radius_y, 0, false, false)
          }
        end
      end

      # @since 1.1.0
      def draw_sector_front_flank(canvas, center_point,
                                  radius_x, radius_y,
                                  arc_start_pt, arc_end_pt,
                                  start_angle, center_angle, options)
        if start_angle < 180
          if 180 < start_angle + center_angle
            draw_closed_path(canvas, arc_start_pt, options) {|path|
              path.arc_to(center_point - [radius_x, 0], radius_x, radius_y)
              path.rline_to([0, dy])
              path.arc_to(arc_start_pt + [0, dy], radius_x, radius_y, 0, false, false)
              if 360 < start_angle + center_angle
                path.close_path
                path.move_to(center_point + [radius_x, 0])
                path.arc_to(arc_end_pt, radius_x, radius_y)
                path.rline_to([0, dy])
                path.arc_to(center_point + [radius_x, dy], radius_x, radius_y, 0, false, false)
              end
            }
          else
            draw_closed_path(canvas, arc_start_pt, options) {|path|
              path.arc_to(arc_end_pt, radius_x, radius_y)
              path.rline_to([0, dy])
              path.arc_to(arc_start_pt + [0, dy], radius_x, radius_y, 0, false, false)
            }
          end
        elsif 540 < start_angle + center_angle
          draw_closed_path(canvas, center_point + [radius_x, 0], options) {|path|
            path.arc_to(center_point - [radius_x, 0], radius_x, radius_y)
            path.rline_to([0, dy])
            path.arc_to(center_point + [radius_x, dy], radius_x, radius_y, 0, false, false)
          }
        elsif 360 < start_angle + center_angle
          draw_closed_path(canvas, center_point + [radius_x, 0], options) {|path|
            path.arc_to(arc_end_pt, radius_x, radius_y)
            path.rline_to([0, dy])
            path.arc_to(center_point + [radius_x, dy], radius_x, radius_y, 0, false, false)
          }
        end
      end
    end
  end
end

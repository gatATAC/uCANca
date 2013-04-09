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

require 'System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
require 'System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'

module DYI
  module Formatter

    # @since 0.0.0
    class EmfFormatter < Base

      def save(file_name, options={})
        form = System::Windows::Forms::Form.new
        tmp_g = form.create_graphics
        dc = tmp_g.get_hdc
        stream = System::IO::FileStream.new(file_name, System::IO::FileMode.create)
#        stream = System::IO::MemoryStream.new()
        metafile = System::Drawing::Imaging::Metafile.new(
            stream,
            dc,
            System::Drawing::Rectangle.new(0, 0, @canvas.width.to_f, @canvas.height.to_f),
            System::Drawing::Imaging::MetafileFrameUnit.pixel,
            System::Drawing::Imaging::EmfType.emf_plus_dual)
        tmp_g.release_hdc
        tmp_g.dispose

        graphics = System::Drawing::Graphics.from_image(metafile);

        @canvas.write_as(self, graphics)

#        fs = System::IO::FileStream.new('test.wmf', System::IO::FileMode.create)
#        fs.write(stream.to_array, 0, stream.length)

        graphics.dispose
        metafile.dispose
      end

      def write_canvas(canvas, graphics)
        canvas.child_elements.each do |element|
          element.write_as(self, graphics)
        end
      end

      def write_rectangle(shape, graphics)
        set_transform(shape, graphics) {
          painting = shape.painting
          if painting.fill
            graphics.fill_rectangle(painting.cls_brush(shape), shape.left.to_f, shape.top.to_f, shape.width.to_f, shape.height.to_f)
          end
          if painting.stroke && (painting.stroke_width != DYI::Length::ZERO)
            graphics.draw_rectangle(painting.cls_pen, shape.left.to_f, shape.top.to_f, shape.width.to_f, shape.height.to_f)
          end
        }
      end

      def write_circle(shape, graphics)
        write_ellipse(shape, graphics)
      end

      def write_ellipse(shape, graphics)
        set_transform(shape, graphics) {
          painting = shape.painting
          if painting.fill
            graphics.fill_ellipse(painting.cls_brush(shape), shape.left.to_f, shape.top.to_f, shape.width.to_f, shape.height.to_f)
          end
          if painting.stroke && (painting.stroke_width != DYI::Length::ZERO)
            graphics.draw_ellipse(painting.cls_pen, shape.left.to_f, shape.top.to_f, shape.width.to_f, shape.height.to_f)
          end
        }
      end

      def write_line(shape, graphics)
        set_transform(shape, graphics) {
          painting = shape.painting
          if painting.stroke && (painting.stroke_width != DYI::Length::ZERO)
            graphics.draw_line(painting.cls_pen, shape.start_point.to_cls_point, shape.end_point.to_cls_point)
          end
        }
      end

      def write_polyline(shape, graphics)
        set_transform(shape, graphics) {
          points = System::Array[System::Drawing::PointF].new(shape.points.size)
          shape.points.each_with_index do |point, i|
            points[i] = point.to_cls_point
          end

          painting = shape.painting
          if painting.stroke && (painting.stroke_width != DYI::Length::ZERO)
            graphics.draw_lines(painting.cls_pen, points)
          end
        }
      end

      def write_polygon(shape, graphics)
        set_transform(shape, graphics) {
          points = System::Array[System::Drawing::PointF].new(shape.points.size)
          shape.points.each_with_index do |point, i|
            points[i] = point.to_cls_point
          end

          painting = shape.painting
          if painting.fill
            graphics.fill_polygon(painting.cls_brush(shape), points, painting.cls_fill_mode)
          end
          if painting.stroke && (painting.stroke_width != DYI::Length::ZERO)
            graphics.draw_polygon(painting.cls_pen, points)
          end
        }
      end

      def write_path(shape, graphics)
        set_transform(shape, graphics) {
          painting = shape.painting
          path = System::Drawing::Drawing2D::GraphicsPath.new(painting.cls_fill_mode)
          path.start_figure
          shape.compatible_path_data.each do |cmd|
            case cmd
            when Shape::Path::MoveCommand
              # do nothing.
            when Shape::Path::CloseCommand
              path.close_figure
            when Shape::Path::LineCommand
              path.add_line(cmd.preceding_point.x.to_f, cmd.preceding_point.y.to_f,
                            cmd.last_point.x.to_f, cmd.last_point.y.to_f)
            when Shape::Path::CurveCommand
              pre_pt = cmd.preceding_point
              ctrl_pt1 = cmd.relative? ? pre_pt + cmd.control_point1 : cmd.control_point1
              ctrl_pt2 = cmd.relative? ? pre_pt + cmd.control_point2 : cmd.control_point2
              path.add_bezier(pre_pt.x.to_f, pre_pt.y.to_f,
                              ctrl_pt1.x.to_f, ctrl_pt1.y.to_f,
                              ctrl_pt2.x.to_f, ctrl_pt2.y.to_f,
                              cmd.last_point.x.to_f, cmd.last_point.y.to_f)
            else
              raise TypeError, "unknown command: #{cmd.class}"
            end
          end
          if painting.fill
            graphics.fill_path(painting.cls_brush(shape), path)
          end
          if painting.stroke && (painting.stroke_width != DYI::Length::ZERO)
            graphics.draw_path(painting.cls_pen, path)
          end
        }
      end

      def write_text(shape, graphics)
        set_transform(shape, graphics) {
#          font = Font.to_cls_font(shape.font)
#          brush = System::Drawing::SolidBrush.new(Color.black.to_cls_color)
          graphics.draw_string(shape.formated_text, shape.font.to_cls_font, shape.painting.cls_brush(shape), shape.point.to_cls_point, shape.string_format)
=begin
        attrs = {:x => shape.point.x, :y => shape.point.y}
        attrs.merge!(common_attributes(shape))
        attrs[:"text-decoration"] = shape.attributes[:text_decoration] if shape.attributes[:text_decoration]
#        attrs[:"alignment-baseline"] = shape.attributes[:alignment_baseline] if shape.attributes[:alignment_baseline]
        case shape.attributes[:alignment_baseline]
          when 'top' then attrs[:y] += shape.font_height * 0.85
          when 'middle' then attrs[:y] += shape.font_height * 0.35
          when 'bottom' then attrs[:y] -= shape.font_height * 0.15
        end
        attrs[:"text-anchor"] = shape.attributes[:text_anchor] if shape.attributes[:text_anchor]
        attrs[:"writing-mode"] = shape.attributes[:writing_mode] if shape.attributes[:writing_mode]
        attrs[:textLength] = shape.attributes[:textLength] if shape.attributes[:textLength]
        attrs[:lengthAdjust] = shape.attributes[:lengthAdjust] if shape.attributes[:lengthAdjust]
        text = shape.formated_text
        if text =~ /(\r\n|\n|\r)/
          create_node(io, 'text', attrs) {
            create_leaf_node(io, 'tspan', $`.strip, :x => shape.point.x)
            $'.each_line do |line|
              create_leaf_node(io, 'tspan', line.strip, :x => shape.point.x, :dy => shape.dy)
            end
          }
        else
          create_leaf_node(io, 'text', text, attrs)
        end
=end
        }
      end

      def write_group(shape, graphics)
        set_transform(shape, graphics) {
          shape.child_elements.each do |element|
            element.write_as(self, graphics)
          end
        }
      end

      private
=begin
      def pre_render(shape)
        attributes = {}
        style = create_style(shape)
        transform = create_transform(shape)
        clip_path = create_clip_path(shape)
        attributes[:style] = style if style
        attributes[:transform] = transform if transform
        attributes[:'clip-path'] = clip_path if clip_path
        attributes
      end
=end
      def set_transform(shape, graphics, &block)
        shape.transform.each do |tr|
          case tr.first
          when :translate
            graphics.translate_transform(tr[1].to_f, tr[2].to_f)
          when :scale
            graphics.scale_transform(tr[1].to_f, tr[2].to_f)
          when :rotate
            graphics.rotate_transform(tr[1].to_f)
          when :skewX
            graphics.multiply_transform(DYI::Matrix.skew_x(tr[1]).to_cls_matrix)
          when :skewY
            graphics.multiply_transform(DYI::Matrix.skew_y(tr[1]).to_cls_matrix)
          end
        end
        yield
        shape.transform.reverse_each do |tr|
          case tr.first
          when :translate
            graphics.translate_transform(-tr[1].to_f, -tr[2].to_f)
          when :scale
            graphics.scale_transform(1.0 / tr[1].to_f, 1.0 / tr[2].to_f)
          when :rotate
            graphics.rotate_transform(-tr[1].to_f)
          when :skewX
            graphics.multiply_transform(DYI::Matrix.skew_x(-tr[1]).to_cls_matrix)
          when :skewY
            graphics.multiply_transform(DYI::Matrix.skew_y(-tr[1]).to_cls_matrix)
          end
        end
      end
    end
  end
end

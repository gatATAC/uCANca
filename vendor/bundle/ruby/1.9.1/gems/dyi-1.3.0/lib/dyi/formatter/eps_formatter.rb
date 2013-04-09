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

require 'nkf'

module DYI
  module Formatter

    # @since 0.0.0
    class EpsFormatter < Base

      def header_comment
        <<-EOS
%!PS-Adobe-3.0 EPSF-3.0
%%Creator: DYI #{DYI::VERSION} (#{DYI::URL})
%%CreationDate: #{Time.now.strftime('%a %b %d %H:%M:%S %Y')}
%%BoundingBox: 0 0 #{@canvas.real_width.to_f('pt').ceil}  #{@canvas.real_height.to_f('pt').ceil}
%%EndComments
        EOS
      end

      def prolog
        <<-EOS
%%BeginProlog
/px { } bind def
/pt { #{Length.unit_ratio('pt')} mul } bind def
/cm { #{Length.unit_ratio('cm')} mul } bind def
/mm { #{Length.unit_ratio('mm')} mul } bind def
/in { #{Length.unit_ratio('in')} mul } bind def
/pc { #{Length.unit_ratio('pc')} mul } bind def
%%EndProlog
        EOS
      end

      def footer_comment
        <<-EOS
%%EOF
        EOS
      end

      def base_transform
        pt_ratio = 1.quo(Length.unit_ratio('pt'))
        <<-EOS
[#{pt_ratio} 0 0 -#{pt_ratio} 0 #{@canvas.real_height * pt_ratio}] concat
        EOS
      end

      def puts(io=$>)
        StringFormat.set_default_formats(:color=>['%.3f %.3f %.3f', true], :length=>'0.### U', :coordinate=>'x y') {
          if @canvas.root_element?
            io << header_comment
            io << prolog
            io << base_transform
          end
          @canvas.write_as(self, io)
          if @canvas.root_element?
            io << footer_comment
          end
        }
      end

      def write_canvas(canvas, io)
        canvas.child_elements.each do |element|
          element.write_as(self, io)
        end
      end

      def write_rectangle(shape, io)
        command_block(io) {
          transform_path(io, shape)
          clip_path(io, shape)
          puts_line(io, 'newpath')
          puts_line(io, shape.left, shape.top, 'moveto')
          puts_line(io, shape.width, 0, 'rlineto')
          puts_line(io, 0, shape.height, 'rlineto')
          puts_line(io, -shape.width, 0, 'rlineto')
          puts_line(io, 'closepath')
          if block_given?
            yield
          else
            fill_current_path(io, shape)
            stroke_current_path(io, shape)
          end
        }
      end

      def write_circle(shape, io)
        command_block(io) {
          transform_path(io, shape)
          clip_path(io, shape)
          puts_line(io, 'newpath')
          puts_line(io, shape.center.x + shape.radius, shape.center.y, 'moveto')
          puts_line(io, shape.center.x, shape.center.y, shape.radius, 0, 360, 'arc')
          if block_given?
            yield
          else
            fill_current_path(io, shape)
            stroke_current_path(io, shape)
          end
        }
      end

      def write_ellipse(shape, io)
        ratio = shape.radius_x.to_f / shape.radius_y.to_f
        command_block(io) {
          transform_path(io, shape)
          clip_path(io, shape)
          puts_line(io, 1, 1.0 / ratio, 'scale')
          puts_line(io, 'newpath')
          puts_line(io, shape.center.x + shape.radius_x, shape.center.y * ratio, 'moveto')
          puts_line(io, shape.center.x, shape.center.y * ratio, shape.radius_x, 0, 360, 'arc')
          if block_given?
            yield
          else
            fill_current_path(io, shape)
            stroke_current_path(io, shape)
          end
        }
      end

      def write_line(shape, io)
        command_block(io) {
          transform_path(io, shape)
          clip_path(io, shape)
          puts_line(io, 'newpath')
          write_lines(io, [shape.start_point, shape.end_point])
          if block_given?
            yield
          else
            stroke_current_path(io, shape)
          end
        }
      end

      def write_polyline(shape, io)
        command_block(io) {
          transform_path(io, shape)
          clip_path(io, shape)
          puts_line(io, 'newpath')
          write_lines(io, shape.points)
          if block_given?
            yield
          else
            fill_current_path(io, shape)
            stroke_current_path(io, shape)
          end
        }
      end

      def write_polygon(shape, io)
        command_block(io) {
          transform_path(io, shape)
          clip_path(io, shape)
          puts_line(io, 'newpath')
          write_lines(io, shape.points)
          puts_line(io, 'closepath')
          if block_given?
            yield
          else
            fill_current_path(io, shape)
            stroke_current_path(io, shape)
          end
        }
      end

      def write_path(shape, io)
        command_block(io) {
          transform_path(io, shape)
          clip_path(io, shape)
          puts_line(io, 'newpath')
          shape.compatible_path_data.each do |cmd|
            case cmd
            when Shape::Path::MoveCommand
              puts_line(io, cmd.point.x, cmd.point.y, cmd.relative? ? 'rmoveto' : 'moveto')
            when Shape::Path::CloseCommand
              puts_line(io, 'closepath')
            when Shape::Path::LineCommand
              puts_line(io, cmd.point.x, cmd.point.y, cmd.relative? ? 'rlineto' : 'lineto')
            when Shape::Path::CurveCommand
              puts_line(io,
                        cmd.control_point1.x, cmd.control_point1.y,
                        cmd.control_point2.x, cmd.control_point2.y,
                        cmd.point.x, cmd.point.y,
                        cmd.relative? ? 'rcurveto' : 'curveto')
            else
              raise TypeError, "unknown command: #{cmd.class}"
            end
          end
          if block_given?
            yield
          else
            fill_current_path(io, shape)
            stroke_current_path(io, shape)
          end
        }
      end

      def write_text(shape, io)
        command_block(io) {
          puts_line(io, '/GothicBBB-Medium-RKSJ-H findfont', shape.font.draw_size, 'scalefont setfont')
          text = NKF.nkf('-s -W', shape.formated_text).unpack('H*').first
          case shape.attributes[:text_anchor]
            when 'middle' then dx = "<#{text}> stringwidth pop -0.5 mul"
            when 'end' then dx = "<#{text}> stringwidth pop -1 mul"
            else dx = "0"
          end
          case shape.attributes[:alignment_baseline]
            when 'top' then y = shape.point.y - shape.font_height * 0.85
            when 'middle' then y = shape.point.y - shape.font_height * 0.35
            when 'bottom' then y = shape.point.y + shape.font_height * 0.15
            else y = shape.point.y
          end
          puts_line(io, "[ 1 0 0 -1 #{dx}", shape.point.y * 2, '] concat')
          puts_line(io, shape.point.x, y, 'moveto')
          puts_line(io, "<#{text}>", 'show')
        }
      end

      def write_group(shape, io)
        command_block(io) {
          transform_path(io, shape)
          clip_path(io, shape)
          shape.child_elements.each do |element|
            element.write_as(self, io)
          end
        } unless shape.child_elements.empty?
      end

      private

      def puts_line(io, *args)
        io << args.flatten.join(' ') << "\n"
      end

      def command_block(io)
        puts_line(io, 'gsave')
        yield
        puts_line(io, 'grestore')
      end

      def stroke_path(io, shape)
        cmds = []
        if shape.respond_to?(:painting) && (attrs = shape.painting)
          cmds.push([attrs.stroke, 'setrgbcolor']) if attrs.stroke
          cmds.push([attrs.stroke_width, 'setlinewidth']) if attrs.stroke_width && attrs.stroke_width.to_f > 0
          cmds.push(['[', attrs.stroke_dasharray, ']', attrs.stroke_dashoffset || 0, 'setdash']) if attrs.stroke_dasharray
          cmds.push([linecap_to_num(attrs.stroke_linecap), 'setlinecap']) if linecap_to_num(attrs.stroke_linecap)
          cmds.push([linejoin_to_num(attrs.stroke_linejoin), 'setlinejoin']) if linejoin_to_num(attrs.stroke_linejoin)
          cmds.push([attrs.stroke_miterlimit, 'setmiterlimit']) if attrs.stroke_miterlimit
        end
        return if cmds.empty?
        command_block(io) {
          cmds.each do |cmd|
            puts_line(io, *cmd)
          end
          yield
        }
      end

      def stroke_current_path(io, shape)
        stroke_path(io, shape) {
          puts_line(io, 'stroke')
        } if shape.painting.stroke
      end

      def fill_path(io, shape)
        cmds = []
        if shape.respond_to?(:painting) && (attrs = shape.painting)
          if attrs.fill
            if attrs.fill.respond_to?(:write_as)
              cmds.push(linear_gradiant_commands(shape, attrs.fill))
            else
              cmds.push([attrs.fill, 'setrgbcolor'])
            end
          end
        end
        return if cmds.empty?
        command_block(io) {
          cmds.each do |cmd|
            puts_line(io, *cmd)
          end
          yield
        }
      end

      def fill_current_path(io, shape)
        fill_path(io, shape) {
          puts_line(io, shape.painting.fill_rule == 'evenodd' ? 'eofill' : 'fill')
        } if shape.painting.fill
      end

      def linecap_to_num(linecap)
        case linecap
          when 'butt' then 0
          when 'round' then 1
          when 'square' then 2
        end
      end

      def linejoin_to_num(linejoin)
        case linejoin
          when 'miter' then 0
          when 'round' then 1
          when 'bevel' then 2
        end
      end

      def write_lines(io, points)
        puts_line(io, points.first.x, points.first.y, 'moveto')
        points[1..-1].each do |pt|
          pt = Coordinate.new(pt)
          puts_line(io, pt.x, pt.y, 'lineto')
        end
      end

      def linear_gradiant_commands(shape, lg)
        x1 = shape.left * (1 - lg.start_point[0]) + shape.right * lg.start_point[0]
        y1 = shape.top * (1 - lg.start_point[1]) + shape.bottom * lg.start_point[1]
        x2 = shape.left * (1 - lg.stop_point[0]) + shape.right * lg.stop_point[0]
        y2 = shape.top * (1 - lg.stop_point[1]) + shape.bottom * lg.stop_point[1]

        last_stop = lg.child_elements.first

        cmds = []
        if last_stop
          lg.child_elements[1..-1].each do |g_stop|
            c1 = last_stop.color
            c2 = g_stop.color
            next unless c1 && c2
            s_x1 = x1 * (1 - last_stop.offset) + x2 * last_stop.offset
            s_y1 = y1 * (1 - last_stop.offset) + y2 * last_stop.offset
            s_x2 = x1 * (1 - g_stop.offset) + x2 * g_stop.offset
            s_y2 = y1 * (1 - g_stop.offset) + y2 * g_stop.offset
            cmds.push(['<< /PatternType 2 /Shading << /ShadingType 2 /ColorSpace /DeviceRGB'])
            cmds.push(['/Coords [', s_x1, s_y1, s_x2, s_y2, ']'])
            cmds.push(['/Function << /FunctionType 2 /Domain [ 0 1 ]'])
            cmds.push(['/C0 [', c1, ']'])
            cmds.push(['/C1 [', c2, ']'])
            cmds.push(['/N 1 >> >> >> matrix makepattern setpattern fill'])
            current_stop = g_stop
          end
        end
        cmds
      end

      def transform_path(io, shape)
        if shape.respond_to?(:transform) && !(tr = shape.transform).empty?
          tr.each do |t|
            case t[0]
            when :translate
              puts_line(io, t[1], t[2], 'translate')
            when :scale
              puts_line(io, t[1], t[2], 'scale')
            when :rotate
              puts_line(io, t[1], t[2], 'rotate')
            when :skewX
              tan = Math.tan(t[1] * Math::PI / 180)
              puts_line(io, '[', 1, 0, tan, 1, 0, 0, ']', 'concat')
            when :skewY
              tan = Math.tan(t[1] * Math::PI / 180)
              puts_line(io, '[', 1, tan, 0, 1, 0, 0, ']', 'concat')
            end
          end
        end
      end

      def clip_path(io, shape)
        if shape.respond_to?(:clipping) && shape.clipping
          shape.clipping.each_shapes do |shape, rule|
            s = shape.clone
            s.painting.fill = nil
            s.painting.stroke = nil
            s.write_as(self, io) {
              puts_line(io, rule == 'evenodd' ? 'eoclip' : 'clip')
            }
          end
        end
      end
    end
  end
end

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

require 'enumerator'

module DYI
  module Shape

    # +Path+ represent the outline of a shape.
    #
    # +Path+ object has a concept of a current point. In an analogy with drawing
    # on paper, the current point can be thought of as the location of the pen.
    # The position of the pen can be changed, and the outline of a shape (open
    # or closed) can be traced by dragging the pen in either straight lines or
    # curves.
    #
    # = Commands of Drawing Paths
    #
    # Lines or curves is drawn using following commad:
    # * <b>_move_to_ commands</b> -- Method {#move_to} and {#rmove_to} establish
    #   a new current point. The effect is as if the "pen" were lifted and moved
    #   to a new location.
    # * <b>_close_path_ command</b> -- Method {#close_path} ends the current
    #   subpath and causes an automatic straight line to be drawn from the
    #   current point to the initial point of the current subpath.
    # * <b>_line_to_ commands</b> -- Method {#line_to} and {#rline_to} draw
    #   straight lines from the current point to a new point.
    # * <b>Cubic Bézier Curve commands</b> -- Method {#curve_to} and {#rcurve_to}
    #   draw a cubic Bézier curve from the current point.
    # * <b>Quadratic Bézier Curve commands</b> -- Method {#quadratic_curve_to}
    #   and {#rquadratic_curve_to} draw a quadratic Bézier curve from the
    #   current point.
    # * <b>Elliptical Arc Curve commands</b> -- Method {#arc_to} and {#rarc_to}
    #   draw an elliptical arc from the current point.
    #
    # See the documentation of each method for more infomation.
    #
    # @since 0.0.0
    class Path < Base
      include Markable

      def initialize(start_point, options={})
        @path_data = case start_point
                       when PathData then start_point
                       else PathData.new(start_point)
                     end
        @attributes = init_attributes(options)
        @marker = {}
      end

      # Starts a new sub-path at a given point, which is specified a absolute
      # coordinate. The new current points become the given point.
      #
      # When multiple points is given as arguments, starts a new sub-path at the
      # first point and draws straight line to the subsequent points. see
      # example.
      # @param [Coordinate] point the absolute coordinate of the start point of
      #   the new sub-path. The second and subsequent arguments are the absolute
      #   point to which the line is drawn from previous point
      # @example
      #   canvas = DYI::Canvas.new(100,100)
      #   pen = DYI::Drawing::Pen.black_pen
      #   pen.draw_path(canvas, [20, 20]) {|path|
      #     path.line_to([20, 50])
      #     path.move_to([30, 20], [30, 50], [40, 50])
      #     # The last expression equals to following expressions
      #     # path.move_to([30, 20])
      #     # path.line_to([30, 50])
      #     # path.line_to([40, 50])
      #   }
      # @see #rmove_to
      def move_to(*points)
        push_command(:move_to, *points)
      end

      # Starts a new sub-path at a given point, which is specified a relative
      # coordinate to current point. The new current point becomes the finally
      # given point.
      #
      # When multiple points is given as arguments, starts a new sub-path at the
      # first point and draws straight line to the subsequent points. see
      # example.
      # @param [Coordinate] point the relative coordinate of the start point of
      #   the new sub-path. The second and subsequent arguments are the relative
      #   point to which the line is drawn from previous point
      # @example
      #   canvas = DYI::Canvas.new(100,100)
      #   pen = DYI::Drawing::Pen.black_pen
      #   pen.draw_path(canvas, [20, 20]) {|path|
      #     path.rline_to([0, 30])
      #     path.rmove_to([10, -30], [0, 30], [10, 0])
      #     # The last expression equals to following expressions
      #     # path.rmove_to([10, -30])
      #     # path.rline_to([0, 30])
      #     # path.rline_to([10, 0])
      #   }
      # @see #move_to
      def rmove_to(*points)
        push_command(:rmove_to, *points)
      end

      # Draws straight lines from the current point to a given point, which is
      # specified a absolute coordinate. The new current point becomes the
      # finally given point.
      #
      # When multiple points is given as argument, draws a polyline. see
      # example.
      # @param [Coordinate] point the absolute coordinate which the line is
      #   drawn from current point to
      # @example
      #   canvas = DYI::Canvas.new(100,100)
      #   pen = DYI::Drawing::Pen.black_pen
      #   pen.draw_path(canvas, [20, 20]) {|path|
      #     path.line_to([20, 50], [30, 20], [30, 50])
      #     # The last expression equals to following expressions
      #     # path.line_to([20, 50])
      #     # path.line_to([30, 20])
      #     # path.line_to([30, 50])
      #   }
      # @see #rline_to
      def line_to(*points)
        push_command(:line_to, *points)
      end

      # Draws straight lines from the current point to a given point, which is
      # specified a relative coordinate to current point. The new current point
      # becomes the finally given point.
      #
      # When multiple points is given as arguments, draws a polyline. see
      # example.
      # @param [Coordinate] point the relavive coordinate which the line is
      #   drawn from current point to
      # @example
      #   canvas = DYI::Canvas.new(100,100)
      #   pen = DYI::Drawing::Pen.black_pen
      #   pen.draw_path(canvas, [20, 20]) {|path|
      #     path.rline_to([0, 30], [10, -30], [0, 30])
      #     # The last expression equals to following expressions
      #     # path.rline_to([0, 30])
      #     # path.rline_to([10, -30])
      #     # path.rline_to([0, 30])
      #   }
      # @see #line_to
      def rline_to(*points)
        push_command(:rline_to, *points)
      end

      # Draws quadratic Bézier curves from the current point to the second
      # argument point using first argument point as control-point. The
      # control-point and pass-point are specified a absolute coordinate. The
      # new current point becomes the point to specify in second argument.
      #
      # When three or more points is given as the argument, draws
      # polybézier-curves. In this case, the control-point is assumed to be the
      # reflection of the control-point on the previouse quadratic Bézier curve
      # relative to the current point. see example.
      # @param [Coordinate] point0 the absolute coordinate of the control-point
      #   of the quadratic Bézier curve
      # @param [Coordinate] point1 the absolute coordinate which the curve is
      #   drawn from current point to
      # @example
      #   canvas = DYI::Canvas.new(100,100)
      #   pen = DYI::Drawing::Pen.black_pen
      #   pen.draw_path(canvas, [20, 20]) {|path|
      #     path.quadratic_curve_to([40, 20], [60, 50], [60, 80])
      #     # The last expression equals to following expressions
      #     # path.quadratic_curve_to([40, 20], [60, 50])
      #     # path.quadratic_curve_to([80, 80], [60, 80])
      #     #     control-point [80,80] is reflection of first curve's control-point [40, 20]
      #     #     across current point [60, 50].
      #   }
      # @see #rquadratic_curve_to
      def quadratic_curve_to(*points)
        raise ArgumentError, "number of points must be 2 or more" if points.size < 2
        push_command(:quadratic_curve_to, points[0], points[1])
        push_command(:shorthand_quadratic_curve_to, *points[2..-1]) if points.size > 2
      end

      # Draws quadratic Bézier curves from the current point to the second
      # argument point using first argument point as control-point. The
      # control-point and pass-point are specified a relative coordinate to
      # current point. The new current point becomes the point to specify in
      # second argument.
      #
      # When three or more points is given as the argument, draws
      # polybézier-curves. In this case, the control-point is assumed to be the
      # reflection of the control-point on the previouse quadratic Bézier curve
      # relative to the current point. see example.
      # @param [Coordinate] point0 the relative coordinate of the control-point
      #   of the quadratic Bézier curve
      # @param [Coordinate] point1 the relative coordinate which the curve is
      #   drawn from current point to
      # @example
      #   canvas = DYI::Canvas.new(100,100)
      #   pen = DYI::Drawing::Pen.black_pen
      #   pen.draw_path(canvas, [20, 20]) {|path|
      #     path.rquadratic_curve_to([20, 0], [40, 30], [0, 30])
      #     # The last expression equals to following expressions
      #     # path.quadratic_curve_to([20, 0], [40, 30])
      #     # path.quadratic_curve_to([20, 30], [0, 30])
      #     #     control-point [20, 30] is reflection of first curve's control-point [-20, -30].
      #     #     (that is relative coordinate to current point. i.e. [20, 0] - [40, 30])
      #   }
      # @see #rquadratic_curve_to
      def rquadratic_curve_to(*points)
        raise ArgumentError, "number of points must be 2 or more" if points.size < 2
        push_command(:rquadratic_curve_to, points[0], points[1])
        push_command(:rshorthand_quadratic_curve_to, *points[2..-1]) if points.size > 2
      end

      def curve_to(*points)
        raise ArgumentError, "number of points must be odd number of 3 or more" if points.size % 2 == 0 || points.size < 3
        push_command(:curve_to, points[0], points[1], points[2])
        push_command(:shorthand_curve_to, *points[3..-1]) if points.size > 3
      end

      def rcurve_to(*points)
        raise ArgumentError, "number of points must be odd number of 3 or more" if points.size % 2 == 0 || points.size < 3
        push_command(:rcurve_to, points[0], points[1], points[2])
        push_command(:rshorthand_curve_to, *points[3..-1]) if points.size > 3
      end

      def arc_to(point, radius_x, radius_y, rotation=0, is_large_arc=false, is_clockwise=true)
        push_command(:arc_to, radius_x, radius_y, rotation, is_large_arc, is_clockwise, point)
      end

      def rarc_to(point, radius_x, radius_y, rotation=0, is_large_arc=false, is_clockwise=true)
        push_command(:rarc_to, radius_x, radius_y, rotation, is_large_arc, is_clockwise, point)
      end

      def close?
        @path_data.close?
      end

      def close_path
        push_command(:close_path)
      end

      def start_point
        @path_data.start_point
      end

      def current_point
        @path_data.current_point
      end

      def current_start_point
        @path_data.current_start_point
      end

      def push_command(command_type, *args)
        @path_data.push_command(command_type, *args)
      end

      def pop_command
        @path_data.pop
      end

      def path_points
        @path_data.path_points
      end

      def path_data
        @path_data
      end

      def compatible_path_data
        @path_data.compatible_path_data
      end

      def concise_path_data
        @path_data.to_concise_syntax
      end

      def left
        edge_coordinate(:left)
      end

      def right
        edge_coordinate(:right)
      end

      def top
        edge_coordinate(:top)
      end

      def bottom
        edge_coordinate(:bottom)
      end

      # Returns whether this shape has a marker symbol.
      # @param [Symbol] point_type the type of marker point. Specifies the
      #   following values: +:start+, +:mid+, +:end+
      # @return [Boolean] true if the shape has a marker at the cpecified point,
      #   false otherwise
      # @since 1.2.0
      def has_marker?(point_type)
        !@marker[point_type].nil?
      end
=begin
      def line_bezier_paths
        start_point = Coordinate::ZERO
        current_point = Coordinate::ZERO
        last_ctrl_point = nil
        @path_data.inject([]) do |result, path_point|
          case path_point.first
          when 'M', 'L', 'C'
            last_ctrl_point = path_point[2]
            current_point = path_point.last
            result << path_point
            start_point = current_point if path_point.first == 'M'
          when 'm', 'l'
            result << [path_point.first.upcase, (current_point += path_point.last)]
            start_point = current_point if path_point.first == 'm'
          when 'c'
            result << [path_point.first.upcase, current_point + path_point[1], (last_ctrl_point = current_point + path_point[2]), (current_point += path_point.last)]
          when 'Z'
            result << path_point
            current_point = start_point
          when 'Q', 'q', 'T', 't'
            case path_point.first
            when 'Q'
              last_ctrl_point = path_point[1]
              last_point = path_point[2]
            when 'q'
              last_ctrl_point = current_point + path_point[1]
              last_point = current_point + path_point[2]
            when 'T'
              last_ctrl_point = current_point * 2 - last_ctrl_point
              last_point = path_point[1]
            when 't'
              last_ctrl_point = current_point * 2 - last_ctrl_point
              last_point = current_point + path_point[1]
            end
            ctrl_point1 = (current_point + last_ctrl_point * 2).quo(3)
            ctrl_point2 = (last_point + last_ctrl_point * 2).quo(3)
            result << ['C', ctrl_point1, ctrl_point2, (current_point = last_point)]
          when 'S', 's'
            case path_point.first
            when 'S'
              ctrl_point1 = current_point * 2 - last_ctrl_point
              ctrl_point2 = path_point[1]
              last_point = path_point[2]
            when 's'
              ctrl_point1 = current_point * 2 - last_ctrl_point
              ctrl_point2 = current_point + path_point[1]
              last_point = current_point + path_point[2]
            end
            result << ['C', ctrl_point1, (last_ctrl_point = ctrl_point2), (current_point = last_point)]
          when 'A', 'a'
            rx, ry, lotate, large_arc, clockwise, last_point = path_point[1..-1]
            last_point += current_point if path_point.first == 'a'
            rx = rx.to_f
            ry = ry.to_f
            lotate = lotate * Math::PI / 180
            cu_pt = Coordinate.new(
              current_point.x * Math.cos(lotate) / rx + current_point.y * Math.sin(lotate) / rx,
              current_point.y * Math.cos(lotate) / ry - current_point.x * Math.sin(lotate) / ry)
            en_pt = Coordinate.new(
              last_point.x * Math.cos(lotate) / rx + last_point.y * Math.sin(lotate) / rx,
              last_point.y * Math.cos(lotate) / ry - last_point.x * Math.sin(lotate) / ry)
            begin
              k = Math.sqrt(4.quo((en_pt.x.to_f - cu_pt.x.to_f) ** 2 + (en_pt.y.to_f - cu_pt.y.to_f) ** 2) - 1) * (large_arc == clockwise ? 1 : -1)
              center_pt = Coordinate.new(
                cu_pt.x - cu_pt.y * k + en_pt.x + en_pt.y * k,
                cu_pt.y + cu_pt.x * k + en_pt.y - en_pt.x * k) * 0.5
              cu_pt -= center_pt
              en_pt -= center_pt
              theta = Math.acos(cu_pt.x.to_f * en_pt.x.to_f + cu_pt.y.to_f * en_pt.y.to_f)
              theta = 2 * Math::PI - theta if large_arc == 1
            rescue
              center_pt = Coordinate.new(cu_pt.x + en_pt.x, cu_pt.y + en_pt.y) * 0.5
              cu_pt -= center_pt
              en_pt -= center_pt
              theta = Math::PI
            end
            d_count = theta.quo(Math::PI / 8).ceil
            d_t = theta / d_count * (clockwise == 1 ? 1 : -1)
            curves = []
            cos = Math.cos(d_t)
            sin = Math.sin(d_t)
            tan = Math.tan(d_t / 4)
            mat = Matrix.new(
              rx * Math.cos(lotate), rx * Math.sin(lotate),
              -ry * Math.sin(lotate), ry * Math.cos(lotate),
              center_pt.x * rx * Math.cos(lotate) - center_pt.y * ry * Math.sin(lotate),
              center_pt.y * ry * Math.cos(lotate) + center_pt.x * rx * Math.sin(lotate))
            d_count.times do |i|
              ne_pt = Coordinate.new(cu_pt.x * cos - cu_pt.y * sin, cu_pt.y * cos + cu_pt.x * sin)
              curves << [
                mat.translate(Coordinate.new(cu_pt.x - cu_pt.y * 4 * tan / 3, cu_pt.y + cu_pt.x * 4 * tan / 3)),
                mat.translate(Coordinate.new(ne_pt.x + ne_pt.y * 4 * tan / 3, ne_pt.y - ne_pt.x * 4 * tan / 3)),
                mat.translate(ne_pt)]
              cu_pt = ne_pt
            end
            curves.last[2] = last_point
            current_point = last_point
            curves.each do |c|
              result << ['C', c[0], c[1], c[2]]
            end
          end
          result
        end
      end
=end
      def write_as(formatter, io=$>)
        formatter.write_path(self, io, &(block_given? ? Proc.new : nil))
      end

      private
=begin
      def edge_coordinate(edge_type)
        case edge_type
        when :left
          element_type = :x
          amount_type = :min
        when :right
          element_type = :x
          amount_type = :max
        when :top
          element_type = :y
          amount_type = :min
        when :bottom
          element_type = :y
          amount_type = :max
        else
          raise ArgumentError, "unknown edge_tpe `#{edge_type}'"
        end
        current_pt = nil
        line_bezier_paths.inject(nil) do |result, path_point|
          case path_point.first
          when 'M', 'L'
            current_pt = path_point.last
            [result, current_pt.__send__(element_type)].compact.__send__(amount_type)
          when 'C'
            pts = [current_pt.__send__(element_type), path_point[1].__send__(element_type), path_point[2].__send__(element_type), path_point[3].__send__(element_type)]
            nums = pts.map {|pt| pt.to_f}
            current_pt = path_point.last
            delta = (nums[2] - nums[1] * 2 + nums[0]) ** 2 - (nums[3] - nums[2] * 3 + nums[1] * 3 - nums[0]) * (nums[1] - nums[0])
            if delta >= 0
              res0 = ((nums[2] - nums[1] * 2 + nums[0]) * (-1) + Math.sqrt(delta)).quo(nums[3] - nums[2] * 3 + nums[1] * 3 - nums[0])
              res1 = ((nums[2] - nums[1] * 2 + nums[0]) * (-1) - Math.sqrt(delta)).quo(nums[3] - nums[2] * 3 + nums[1] * 3 - nums[0])
              res0 = (0..1).include?(res0) ? Length.new(res0) : nil
              res1 = (0..1).include?(res1) ? Length.new(res1) : nil
              [result, pts[0], pts[3], res0, res1].compact.__send__(amount_type)
            else
              [result, pts[0], pts[3]].conpact.__send__(amount_type)
            end
          else
            result
          end
        end
      end
=end
      class << self

        public

        def draw(start_point, options={}, &block)
          path = new(start_point, options)
          yield path
          path
        end

        def draw_and_close(start_point, options={}, &block)
          path = draw(start_point, options, &block)
          path.close_path unless path.close?
          path
        end
      end

      class PathData
        include Enumerable

        def initialize(*points)
          raise ArgumentError, 'wrong number of arguments (0 for 1)' if points.empty?
          @commands = MoveCommand.absolute_commands(nil, *points)
        end

        def each
          if block_given?
            @commands.each{|command| yield command}
          else
            @commands.each
          end
        end

        def push_command(command_type, *args)
          case command_type
          when :move_to
            @commands.push(*MoveCommand.absolute_commands(@commands.last, *args))
          when :rmove_to
            @commands.push(*MoveCommand.relative_commands(@commands.last, *args))
          when :close_path
            @commands.push(*CloseCommand.commands(@commands.last))
          when :line_to
            @commands.push(*LineCommand.absolute_commands(@commands.last, *args))
          when :rline_to
            @commands.push(*LineCommand.relative_commands(@commands.last, *args))
          when :horizontal_lineto_to
            @commands.push(*HorizontalLineCommand.absolute_commands(@commands.last, *args))
          when :rhorizontal_lineto_to
            @commands.push(*HorizontalLineCommand.relative_commands(@commands.last, *args))
          when :vertical_lineto_to
            @commands.push(*VerticalLineCommand.absolute_commands(@commands.last, *args))
          when :rvertical_lineto_to
            @commands.push(*VerticalLineCommand.relative_commands(@commands.last, *args))
          when :curve_to
            @commands.push(*CurveCommand.absolute_commands(@commands.last, *args))
          when :rcurve_to
            @commands.push(*CurveCommand.relative_commands(@commands.last, *args))
          when :shorthand_curve_to
            @commands.push(*ShorthandCurveCommand.absolute_commands(@commands.last, *args))
          when :rshorthand_curve_to
            @commands.push(*ShorthandCurveCommand.relative_commands(@commands.last, *args))
          when :quadratic_curve_to
            @commands.push(*QuadraticCurveCommand.absolute_commands(@commands.last, *args))
          when :rquadratic_curve_to
            @commands.push(*QuadraticCurveCommand.relative_commands(@commands.last, *args))
          when :shorthand_quadratic_curve_to
            @commands.push(*ShorthandQuadraticCurveCommand.absolute_commands(@commands.last, *args))
          when :rshorthand_quadratic_curve_to
            @commands.push(*ShorthandQuadraticCurveCommand.relative_commands(@commands.last, *args))
          when :arc_to
            @commands.push(*ArcCommand.absolute_commands(@commands.last, *args))
          when :rarc_to
            @commands.push(*ArcCommand.relative_commands(@commands.last, *args))
          else
            raise ArgumentError, "unknown command type `#{command_type}'"
          end
        end

        def pop_command
          @commands.pop
        end

        def compatible_path_data
          new_instance = clone
          new_instance.commands = compatible_path_commands
          new_instance
        end

        def compatible_path_data!
          @commands = compatible_path_commands
          self
        end

        def start_point
          @commands.first.start_point
        end

        def current_point
          @commands.last.last_point
        end

        def current_start_point
          @commands.last.start_point
        end

        def path_points
          @commands.map{|command| command.points}.flatten
        end

        def close?
          @commands.last.is_a?(CloseCommand)
        end

        def to_concise_syntax
          @commands.map{|command| command.to_concise_syntax_fragments}.join(' ')
        end

        protected

        def commands=(value)
          @commands = value
        end

        private

        def compatible_path_commands
          @commands.inject([]) do |compat_cmds, command|
            compat_cmds.push(*command.to_compatible_commands(compat_cmds.last))
          end
        end
      end

      class CommandBase
        attr_reader :preceding_command, :point

        def initialize(relative, preceding_command, point)
          @relative = relative
          @preceding_command = preceding_command
          @point = Coordinate.new(point)
        end

        def relative?
          @relative
        end

        def absolute?
          !relative?
        end

        def start_point
          preceding_command.start_point
        end

        def last_point
          relative? ? preceding_point + @point : @point
        end

        def preceding_point
          preceding_command && preceding_command.last_point
        end

        def to_compatible_commands(preceding_command)
          compat_commands = clone
          compat_commands.preceding_command = preceding_command
          compat_commands
        end

        def used_same_command?
          preceding_command.instructions_char == instructions_char
        end

        protected

        def preceding_command=(value)
          @preceding_command = preceding_command
        end

        class << self
          def relative_commands(preceding_command, *args)
            commands(true, preceding_command, *args)
          end

          def absolute_commands(preceding_command, *args)
            commands(false, preceding_command, *args)
          end
        end
      end

      class MoveCommand < CommandBase

        def start_point
          last_point
        end

        def last_point
          (relative? && preceding_command.nil?) ? point : super
        end

        def relative?
          preceding_command.nil? ? false : super
        end

        def to_concise_syntax_fragments
          instructions_char + @point.to_s
        end

        def instructions_char
          relative? ? 'm' : 'M'
        end

        class << self
          def commands(relative, preceding_command, *points)
            raise ArgumentError, 'wrong number of arguments (2 for 3)' if points.empty?
            commands = [new(relative, preceding_command, points.first)]
            points[1..-1].inject(commands) do |cmds, pt|
              cmds << LineCommand.new(relative, cmds.last, pt)
            end
          end
        end
      end

      class CloseCommand < CommandBase
        def initialize(preceding_command)
          raise ArgumentError, 'preceding_command is nil' if preceding_command.nil?
          @relative = nil
          @preceding_command = preceding_command
          @point = nil
        end

        def last_point
          start_point
        end

        def relative?
          nil
        end

        def absolute?
          nil
        end

        def to_concise_syntax_fragments
          instructions_char
        end

        def instructions_char
          'Z'
        end

        class << self
          undef relative_commands, absolute_commands

          def commands(preceding_command)
            [new(preceding_command)]
          end
        end
      end

      class LineCommand < CommandBase
        def initialize(relative, preceding_command, point)
          raise ArgumentError, 'preceding_command is nil' if preceding_command.nil?
          super
        end

        def to_concise_syntax_fragments
          used_same_command? ? @point.to_s : (instructions_char + @point.to_s)
        end

        def instructions_char
          relative? ? 'l' : 'L'
        end

        class << self
          def commands(relative, preceding_command, *points)
            raise ArgumentError, 'wrong number of arguments (2 for 3)' if points.empty?
            cmd = preceding_command
            points.inject([]) do |cmds, pt|
              cmds << (cmd = new(relative, cmd, pt))
            end
          end
        end
      end

      class HorizontalLineCommand < LineCommand
        def initialize(relative, preceding_command, x)
          super(relative, preceding_command, Coordinate.new(x, relative ? 0 : preceding_command.last_point.y))
        end

        def to_compatible_commands(preceding_command)
          LineCommand.new(relative?, preceding_command, @point)
        end

        def to_concise_syntax_fragments
          used_same_command? ? @point.x.to_s : (instructions_char + @point.x.to_s)
        end

        def instructions_char
          relative? ? 'h' : 'H'
        end
      end

      class VerticalLineCommand < LineCommand
        def initialize(relative, preceding_command, y)
          super(relative, preceding_command, Coordinate.new(relative ? 0 : preceding_command.last_point.x, y))
        end

        def to_compatible_commands(preceding_command)
          LineCommand.new(relative?, preceding_command, @point)
        end

        def to_concise_syntax_fragments
          used_same_command? ? @point.y.to_s : (instructions_char + @point.y.to_s)
        end

        def instructions_char
          relative? ? 'v' : 'V'
        end
      end

      class CurveCommandBase < CommandBase
        def initialize(relative, preceding_command, *points)
          raise ArgumentError, "wrong number of arguments (2 for #{pt_cnt + 2})" if points.size != pt_cnt
          raise ArgumentError, 'preceding_command is nil' if preceding_command.nil?
          @relative = relative
          @preceding_command = preceding_command
          @point = Coordinate.new(points.last)
          @control_points = points[0..-2].map{|pt| Coordinate.new(pt)}
        end

        def last_control_point
          relative? ? (preceding_point + @control_points.last) : @control_points.last
        end

        def to_concise_syntax_fragments
          used_same_command? ? @point.to_s : (instructions_char + @point.to_s)
        end

        def to_concise_syntax_fragments
          fragments = @control_points.map{|ctrl_pt| ctrl_pt.to_s}.push(@point.to_s)
          fragments[0] = instructions_char + fragments[0] unless used_same_command?
          fragments
        end

        private

        def pt_cnt
          self.class.pt_cnt
        end

        class << self
          def commands(relative, preceding_command, *points)
            raise ArgumentError, "number of points must be a multipule of #{pt_cnt}" if points.size % pt_cnt != 0
            cmd = preceding_command
            points.each_slice(pt_cnt).inject([]) do |cmds, pts|
              cmds << (cmd = new(relative, cmd, *pts))
            end
          end
        end
      end

      class CurveCommand < CurveCommandBase
        def preceding_control_point
          if preceding_command.is_a?(CurveCommand)
            preceding_command.last_control_point
          else
            preceding_command.last_point
          end
        end

        def control_point1
          @control_points[0]
        end

        def control_point2
          @control_points[1]
        end

        def instructions_char
          relative? ? 'c' : 'C'
        end

        class << self
          def pt_cnt
            3
          end
        end
      end

      class ShorthandCurveCommand < CurveCommand
        def control_point1
          if relative?
            preceding_point - preceding_control_point
          else
            preceding_point * 2 - preceding_control_point
          end
        end

        def control_point2
          @control_points[0]
        end

        def to_compatible_commands(preceding_command)
          CurveCommand.new(relative?, preceding_command, control_point1, control_point2, @point)
        end

        def instructions_char
          relative? ? 's' : 'S'
        end

        class << self
          def pt_cnt
            2
          end
        end
      end

      class QuadraticCurveCommand < CurveCommandBase
        def preceding_control_point
          if preceding_command.is_a?(QuadraticCurveCommand)
            preceding_command.last_control_point
          else
            preceding_command.last_point
          end
        end

        def control_point
          @control_points[0]
        end

        def to_compatible_commands(preceding_command)
          ctrl_pt1 = relative? ? control_point * 2.0 / 3.0 : (preceding_point + control_point * 2.0) / 3.0
          ctrl_pt2 = (control_point * 2.0 + point) / 3.0
          CurveCommand.new(relative?, preceding_command, ctrl_pt1, ctrl_pt2, @point)
        end

        def instructions_char
          relative? ? 'q' : 'Q'
        end

        class << self
          def pt_cnt
            2
          end
        end
      end

      class ShorthandQuadraticCurveCommand < QuadraticCurveCommand
        def control_point
          if relative?
            preceding_point - preceding_control_point
          else
            preceding_point * 2 - preceding_control_point
          end
        end

        def last_control_point
          preceding_point * 2 - preceding_control_point
        end

        def instructions_char
          relative? ? 't' : 'T'
        end

        class << self
          def pt_cnt
            1
          end
        end
      end

      class ArcCommand < CommandBase
        attr_reader :rx, :ry, :rotation

        def initialize(relative, preceding_command, rx, ry, rotation, is_large_arc, is_clockwise, point)
          raise ArgumentError, 'preceding_command is nil' if preceding_command.nil?
          @relative = relative
          @preceding_command = preceding_command
          @point = Coordinate.new(point)
          @rotation = rotation
          @is_large_arc = is_large_arc
          @is_clockwise = is_clockwise
          @rx = Length.new(rx).abs
          @ry = Length.new(ry).abs
          l = (modified_mid_point.x.to_f / @rx.to_f) ** 2 + (modified_mid_point.y.to_f / @ry.to_f) ** 2
          if 1 < l
            @rx *= Math.sqrt(l)
            @ry *= Math.sqrt(l)
          end
        end

        def large_arc?
          @is_large_arc
        end

        def clockwise?
          @is_clockwise
        end

        def to_compatible_commands(preceding_command)
          return LineCommand.new(relative?, preceding_command, point) if rx.zero? || ry.zero?
          division_count = (center_angle / 30.0).ceil
          division_angle = center_angle / division_count * (clockwise? ? 1 : -1)
          current_point = start_angle_point
          compat_commands = []
          division_count.times do |i|
            end_point = if i == division_count - 1
                          end_angle_point
                        else
                          Matrix.rotate(division_angle).transform(current_point)
                        end
            control_point1 = control_point_of_curve(current_point, division_angle, true)
            control_point2 = control_point_of_curve(end_point, division_angle, false)
            path_point = (i == division_count - 1) ? point : transform_orginal_shape(end_point)
            if relative?
              control_point1 += preceding_point
              control_point2 += preceding_point
              path_point += preceding_point
            end
            preceding_command = CurveCommand.absolute_commands(preceding_command,
                                                               control_point1,
                                                               control_point2,
                                                               path_point).first
            compat_commands << preceding_command
            current_point = end_point
          end
          compat_commands
        end

        def to_concise_syntax_fragments
          [used_same_command? ? rx.to_s : instructions_char + rx.to_s,
           ry, rotation, large_arc? ? 1 : 0, clockwise? ? 1 : 0, point.to_s]
        end

        def instructions_char
          relative? ? 'a' : 'A'
        end

        def center_point
          st_pt = relative? ? Coordinate::ZERO : preceding_point
          Matrix.rotate(rotation).transform(modified_center_point) + (st_pt + point) * 0.5
        end

        private

        def modified_mid_point
          st_pt = relative? ? Coordinate::ZERO : preceding_point
          Matrix.rotate(-rotation).transform((st_pt - point) * 0.5)
        end

        def modified_center_point
          pt = modified_mid_point
          Coordinate.new(pt.y * (rx / ry), -pt.x * (ry / rx)) *
            Math.sqrt(((rx.to_f * ry.to_f) ** 2 - (rx.to_f * pt.y.to_f) ** 2 - (ry.to_f * pt.x.to_f) ** 2) /
              ((rx.to_f * pt.y.to_f) ** 2 + (ry.to_f * pt.x.to_f) ** 2)) *
            ((large_arc? == clockwise?) ? -1 : 1)
        end

        def start_angle_point
          Coordinate.new((modified_mid_point.x - modified_center_point.x) / rx,
                         (modified_mid_point.y - modified_center_point.y) / ry)
        end

        def end_angle_point
          Coordinate.new((-modified_mid_point.x - modified_center_point.x) / rx,
                         (-modified_mid_point.y - modified_center_point.y) / ry)
        end

        def center_angle
          angle = DYI::Util.acos(start_angle_point.x.to_f * end_angle_point.x.to_f +
                            start_angle_point.y.to_f * end_angle_point.y.to_f)
          large_arc? ? 360.0 - angle : angle
        end

        def transform_matrix
          Matrix.translate(center_point.x.to_f, center_point.y.to_f).rotate(rotation).scale(rx.to_f, ry.to_f)
        end

        def transform_orginal_shape(modified_point)
          transform_matrix.transform(modified_point)
        end

        def control_point_of_curve(point, center_angle, is_start_point)
          handle_length = DYI::Util.tan(center_angle / 4.0) * 4.0 / 3.0
          handle = is_start_point ? handle_length : -handle_length
          transform_matrix.transform(Matrix.new(1, handle, -handle, 1, 0, 0).transform(point))
        end

        class << self
          def commands(relative, preceding_command, *args)
            raise ArgumentError, "number of arguments must be a multipule of 6" if args.size % 6 != 0
            cmd = preceding_command
            args.each_slice(6).inject([]) do |cmds, ars|
              if ars[0].zero? || ars[1].zero?
                cmds << (cmd = LineCommand.new(relative, cmd, ars.last))
              else
                cmds << (cmd = new(relative, cmd, *ars))
              end
            end
          end
        end
      end
    end
  end
end

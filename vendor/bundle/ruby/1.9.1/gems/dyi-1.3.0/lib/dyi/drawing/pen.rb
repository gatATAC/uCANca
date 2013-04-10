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

    # A factory base class for createing a shape in the image.
    #
    # +PenBase+ object holds a {Painting} object and a {Font} object. Using
    # these object, +PenBase+ object creates instances of concrete subclass of
    # {Shape::Base}; a created instance has a painting attribute and a font
    # attribute that +PenBase+ object holds.
    #
    # This class has same attributes as {Painting}, these attributs access
    # {Painting} object that +PenBase+ object holds.
    # @abstract
    # @see Painting
    # @see Brush
    # @see Pen
    # @since 0.0.0
    class PenBase
      extend AttributeCreator

      # @private
      DROP_SHADOW_OPTIONS = [:blur_std, :dx, :dy]
      attr_font :font

      # @private
      attr_reader :drop_shadow

      # @option options [Font, Hash] :font the value of attribute {#font font}
      # @option (see Painting#initialize)
      def initialize(options={})
        @attributes = {}
        @painting = Painting.new
        options.each do |key, value|
          if key.to_sym == :font
            self.font = value
          elsif Painting::IMPLEMENT_ATTRIBUTES.include?(key)
            @painting.__send__("#{key}=", value)
          else
            @attributes[key] = value
          end
        end
      end

      # @attribute opacity
      # Returns or sets opacity of the paiting operation. Opacity of Both +stroke+
      # and +fill+ is set at the same time by this attribute.
      # @return [Float] the value of attribute opacity
      # @since 1.0.0
      #+++
      # @attribute fill
      # Returns or sets the interior painting of the shape.
      # @return [Color, #write_as] the value of attribute fill
      #+++
      # @attribute fill_opacity
      # Returns or sets the opacity of the paiting operation used to paint the
      # interior of the shape.
      # @return [Float] the value of attribute fill_opacity
      #+++
      # @attribute fill_rule
      # Returns or sets the rule which is to be used to detemine what parts of the
      # canvas are included inside the shape. specifies one of the following
      # values: <tt>"nonzero"</tt>, <tt>"evenodd"</tt>
      # @return [String] the value of attribute fill_rule
      #+++
      # @attribute stroke
      # Returns or sets the painting along the outline of the shape.
      # @return [Color, #write_as] the value of attribute stroke
      #+++
      # @attribute stroke_dasharray
      # Returns or sets the pattern of dashes and gaps used to stroke paths.
      # @return [Array<Length>] the value of attribute stroke_dasharray
      #+++
      # @attribute stroke_dashoffset
      # Returns or sets the distance into the dash pattern to start the dash.
      # @return [Length] the value of attribute stroke_dashoffset
      #+++
      # @attribute stroke_linecap
      # Returns or sets the shape to be used at the end of open subpaths when they
      # are stroked. specifies one of the following values: <tt>"butt"</tt>,
      # <tt>"round"</tt>, <tt>"square"</tt>
      # @return [String] the value of attribute stroke_linecap
      #+++
      # @attribute stroke_linejoin
      # Returns or sets the shape to be used at the corners of paths or basic
      # shapes when they are stroked. specifies one of the following vlaues:
      # <tt>"miter"</tt>, <tt>"round"</tt>, <tt>"bevel"</tt>
      # @return [String] the value of attribute stroke_linejoin
      #+++
      # @attribute stroke_miterlimit
      # Returns or sets the limit value on the ratio of the miter length to the
      # value of +stroke_width+ attribute. When the ratio exceeds this attribute
      # value, the join is converted from a _miter_ to a _bevel_.
      # @return [Float] the value of attribute stroke_mitterlimit
      #+++
      # @attribute stroke_opacity
      # Returns or sets the opacity of the painting operation used to stroke.
      # @return [Float] the value of attribute stroke_opacity
      #+++
      # @attribute stroke_width
      # Returns or sets the width of the stroke.
      # @return [Length] the value of attribute stroke_width
      #+++
      # @attribute display
      # Returns or sets whether the shape is displayed. specifies one of the
      # following vlaues: <tt>"block"</tt>, <tt>"none"</tt>
      # @return [String] the value of attribute display
      #+++
      # @attribute visibility
      # Returns or sets whether the shape is hidden. specifies one of the
      # following vlaues: <tt>"visible"</tt>, <tt>"hidden"</tt>
      # @return [String] the value of attribute visibility
      Painting::IMPLEMENT_ATTRIBUTES.each do |painting_attr|
        define_method(painting_attr) {| | @painting.__send__(painting_attr)}
        define_method("#{painting_attr}=".to_sym) {|value|
          @painting = @painting.clone
          @painting.__send__("#{painting_attr}=".to_sym, value)
        }
      end

      # @private
      # @todo
      def drop_shadow=(options)
        DROP_SHADOW_OPTIONS.each do |key|
          @drop_shadow[key] = options[key.to_sym] if options[key.to_sym]
        end
      end

      # Draws a line to specify the start and end points.
      # @param [Element] canvas the element which the line is drawn on
      # @param [Coordinate] start_point the start point of the line
      # @param [Coordinate] end_point the start point of the line
      # @option options [String] :id the ID of the drawn shape
      # @option options [String] :anchor_href the location of a reference of a
      #   source anchor for the link of the drawn shape
      # @option options [String] :anchor_target the relevant presentation
      #   context when the link is activated
      # @option options [String] :css_class the CSS class attribute of the drawn
      #   shape
      # @return [Shape::Line] a drawn line
      def draw_line(canvas, start_point, end_point, options={})
        Shape::Line.create_on_start_end(start_point, end_point, merge_option(options)).draw_on(canvas)
      end

      alias draw_line_on_start_end draw_line

      # Draws a line to specify the start points and the direction.
      # @param [Element] canvas the element which the line is drawn on
      # @param [Coordinate] start_point the start point of the line
      # @param [Length] direction_x the x-direction of the end point
      # @param [Length] direction_y the y-direction of the end point
      # @option (see #draw_line)
      # @return (see #draw_line)
      def draw_line_on_direction(canvas, start_point, direction_x, direction_y, options={})
        Shape::Line.create_on_direction(start_point, direction_x, direction_y, merge_option(options)).draw_on(canvas)
      end

      # Draws a polyline.
      # @return [Shape::Polyline] a drawn polyline
      # @overload draw_polyline(canvas, point, options = {})
      #   Draws a polyline. Second and subsequent making-up points are specified in the
      #   block.
      #   @param [Element] canvas the element which the polyline is drawn on
      #   @param [Coordinate] point the start point of the polyline
      #   @option options [String] :id the ID of the drawn shape
      #   @option options [String] :anchor_href the location of a reference of a
      #     source anchor for the link of the drawn shape
      #   @option options [String] :anchor_target the relevant presentation
      #     context when the link is activated
      #   @option options [String] :css_class the CSS class attribute of the drawn
      #     shape
      #   @yield [polyline] a block which the polyline is drawn in
      #   @yieldparam [Shape::Polyline] polyline the created polyline object
      # @overload draw_polyline(canvas, points, options = {})
      #   Draws a polyline to specify in the making-up points.
      #   @param [Element] canvas the element which the polyline is drawn on
      #   @param [Array<Coordinate>] points the array of the making-up points
      #   @option options [String] :id the ID of the drawn shape
      #   @option options [String] :anchor_href the location of a reference of a
      #     source anchor for the link of the drawn shape
      #   @option options [String] :anchor_target the relevant presentation
      #     context when the link is activated
      #   @option options [String] :css_class the CSS class attribute of the drawn
      #     shape
      #   @since 1.1.0
      # @example
      #   canvas = DYI::Canvas.new(100,100)
      #   pen = DYI::Drawing::Pen.black_pen
      #   pen.draw_polyline(canvas, [20, 20]) {|polyline|
      #     polyline.line_to([20, 80])
      #     polyline.line_to([80, 80])
      #   }
      #   # the following is the same processing
      #   # pen.draw_polyline(canvas, [[20, 20], [20, 80], [80, 80]])
      def draw_polyline(canvas, points, options={})
        if block_given?
          polyline = Shape::Polyline.new(points, merge_option(options))
          yield polyline
        else
          polyline = Shape::Polyline.new(points.first, merge_option(options))
          polyline.line_to(*points[1..-1])
        end
        polyline.draw_on(canvas)
      end

      # Draws a polygon.
      # @return [Shape::Polygon] a drawn polygon
      # @overload draw_polygon(canvas, point, options = {})
      #   Draws a polygon. Second and subsequent vertices are specified in the
      #   block.
      #   @param [Element] canvas the element which the polygon is drawn on
      #   @param [Coordinate] point the first vertix of the polygon
      #   @option options [String] :id the ID of the drawn shape
      #   @option options [String] :anchor_href the location of a reference of a
      #     source anchor for the link of the drawn shape
      #   @option options [String] :anchor_target the relevant presentation
      #     context when the link is activated
      #   @option options [String] :css_class the CSS class attribute of the drawn
      #     shape
      #   @yield [polygon] a block which the polygon is drawn in
      #   @yieldparam [Shape::Polygon] polygon the created polygon object
      # @overload draw_polygon(canvas, points, options = {})
      #   Draws a polygon to specify in the vertices.
      #   @param [Element] canvas the element which the polygon is drawn on
      #   @param [Array<Coordinate>] points the array of the vertices
      #   @option options [String] :id the ID of the drawn shape
      #   @option options [String] :anchor_href the location of a reference of a
      #     source anchor for the link of the drawn shape
      #   @option options [String] :anchor_target the relevant presentation
      #     context when the link is activated
      #   @option options [String] :css_class the CSS class attribute of the drawn
      #     shape
      #   @since 1.1.0
      # @example
      #   canvas = DYI::Canvas.new(100,100)
      #   brush = DYI::Drawing::Brush.red_brush
      #   brush.draw_polygon(canvas, [20, 20]) {|polygon|
      #     polygon.line_to([20, 80])
      #     polygon.line_to([80, 80])
      #   }
      #   # the following is the same processing
      #   # brush.draw_polygon(canvas, [[20, 20], [20, 80], [80, 80]])
      def draw_polygon(canvas, points, options={})
        if block_given?
          polygon = Shape::Polygon.new(points, merge_option(options))
          yield polygon
        else
          polygon = Shape::Polygon.new(points.first, merge_option(options))
          polygon.line_to(*points[1..-1])
        end
        polygon.draw_on(canvas)
      end

      # Draws a rectangle to specify the left-top points, the width and the
      # height.
      # @param [Element] canvas the element which the rectangle is drawn on
      # @param [Coordinate] left_top the left-top corner point of the rectangle
      # @param [Length] width the width of the rectangle
      # @param [Length] height the height of the rectangle
      # @option (see #draw_line)
      # @option options [Length] :rx for rounded rectangles, the x-axis radius
      #   of the ellipse used to round off the corners of the rectangle
      # @option options [Length] :ry for rounded rectangles, the y-axis radius
      #   of the ellipse used to round off the corners of the rectangle
      # @return [Shape::Rectangle] a drawn rectangle
      def draw_rectangle(canvas, left_top_point, width, height, options={})
        Shape::Rectangle.create_on_width_height(left_top_point, width, height, merge_option(options)).draw_on(canvas)
      end

      alias draw_rectangle_on_width_height draw_rectangle

      # Draws a rectangle to specify the top, right, botton and left cooridinate.
      # @param [Element] canvas the element which the rectangle is drawn on
      # @param [Length] top the y-coordinate of the top of the rectangle
      # @param [Length] right the x-coordinate of the right of the rectangle
      # @param [Length] bottom the y-coordinate of the bottom of the rectangle
      # @param [Length] left the x-coordinate of the left of the rectangle
      # @option (see #draw_rectangle)
      # @return (see #draw_rectangle)
      def draw_rectangle_on_corner(canvas, top, right, bottom, left, options={})
        Shape::Rectangle.create_on_corner(top, right, bottom, left, merge_option(options)).draw_on(canvas)
      end

      # Draws free-form lines or curves. See methods of {Shape::Path} for
      # commands to draw the path.
      # @param [Element] canvas the element which the path is drawn on
      # @param [Coordinate] point the start point of the path
      # @option (see #draw_line)
      # @yield [path] a block which the path is drawn in
      # @yieldparam [Shape::Path] path the created path object
      # @return [Shape::Path] a drawn path
      # @see Shape::Path
      def draw_path(canvas, point, options={}, &block)
        path = Shape::Path.new(point, merge_option(options)).draw_on(canvas)
        yield path
        path
      end

      # Draws a free-form line or curve, and closes path finally. See methods of
      # {Shape::Path} for commands to draw the path.
      # @param (see #draw_path)
      # @option (see #draw_path)
      # @yield (see #draw_path)
      # @yieldparam (see #draw_path)
      # @return (see #draw_path)
      # @see (see #draw_path)
      def draw_closed_path(canvas, point, options={}, &block)
        path = draw_path(canvas, point, options, &block)
        path.close_path unless path.close?
        path
      end

      # Draws a circle to specify the center point and the radius.
      # @param [Element] canvas the element which the circle is drawn on
      # @param [Coordinate] center_point the center point of the circle
      # @param [Length] radius the radius of the circle
      # @option (see #draw_line)
      # @return [Shape::Circle] a drawn circle
      def draw_circle(canvas, center_point, radius, options={})
        Shape::Circle.create_on_center_radius(center_point, radius, merge_option(options)).draw_on(canvas)
      end

      # Draws an ellipse to specify the center point and the radius.
      # @param [Element] canvas the element which the ellipse is drawn on
      # @param [Coordinate] center_point the center point of the ellipse
      # @param [Length] radius_x the x-axis radius of the ellipse
      # @param [Length] radius_y the y-axis radius of the ellipse
      # @option (see #draw_line)
      # @return [Shape::Ellipse] a drawn ellipse
      def draw_ellipse(canvas, center_point, radius_x, radius_y, options={})
        Shape::Ellipse.create_on_center_radius(center_point, radius_x, radius_y, merge_option(options)).draw_on(canvas)
      end

      # Draws an image.
      # @param [Element] canvas the element which the image is drawn on
      # @param [Coordinate] left_top the left-top corner point of the image
      # @param [Length] width the width of the image
      # @param [Length] height the height of the image
      # @param [String] file_path the path of the image file
      # @option (see #draw_line)
      # @option options [String] :content_type the content-type of the image
      # @return [Shape::Image] a drawn image
      # @since 1.0.0
      def draw_image(canvas, left_top_point, width, height, file_path, options={})
        Shape::Image.new(left_top_point, width, height, file_path, merge_option(options)).draw_on(canvas)
      end

      # Adds a reference to an image.
      # @param [Element] canvas the element which the reference is added on
      # @param [Coordinate] left_top the left-top corner point of the image
      # @param [Length] width the width of the image
      # @param [Length] height the height of the image
      # @param [String] image_uri the reference URI to the image file
      # @option (see #draw_line)
      # @return [Shape::ImageReference] a drawn reference to the image
      # @since 1.0.0
      def import_image(canvas, left_top_point, width, height, image_uri, options={})
        Shape::ImageReference.new(left_top_point, width, height, image_uri, merge_option(options)).draw_on(canvas)
      end

      # Draws a circular sector.
      # @param [Element] canvas the element which the sector is drawn on
      # @param [Coordinate] center_point the center point of the sector
      # @param [Length] radius_x the x-axis radius of the sector
      # @param [Length] radius_y the y-axis radius of the sector
      # @param [Number] start_angle the starting-radius angle of the sector from
      #   x-direction in degrees
      # @param [Number] center_angle the center angle of the sector from the
      #   starting-radius in degrees
      # @option (see #draw_line)
      # @option options [#to_f] :inner_radius if you want to make a concentric
      #   hole with sector, the ratio of the hole's radius to the sector radius
      # @return [Shape::Path] a drawn sector
      # @raise [ArgumentError] _:inner_radius_ option is out of range
      def draw_sector(canvas, center_point, radius_x, radius_y, start_angle, center_angle, options={})
        start_angle = (center_angle > 0 ? start_angle : (start_angle + center_angle)) % 360
        center_angle = center_angle.abs
        options = merge_option(options)
        inner_radius = options.delete(:inner_radius).to_f
        center_point = Coordinate.new(center_point)
        radius_x = Length.new(radius_x).abs
        radius_y = Length.new(radius_y).abs
        large_arc = (center_angle.abs > 180)

        if inner_radius >= 1 || 0 > inner_radius
          raise ArgumentError, "inner_radius option is out of range: #{inner_radius}"
        end
        if 360 <= center_angle
          if inner_radius == 0.0
            draw_ellipse(canvas, center_point, radius_x, radius_y, options)
          else
            draw_toroid(canvas, center_point, radius_x, radius_y, inner_radius, options)
          end
        else
          arc_start_pt = Coordinate.new(
              radius_x * DYI::Util.cos(start_angle),
              radius_y * DYI::Util.sin(start_angle)) + center_point
          arc_end_pt = Coordinate.new(
              radius_x * DYI::Util.cos(start_angle + center_angle),
              radius_y * DYI::Util.sin(start_angle + center_angle)) + center_point

          draw_sector_internal(canvas, center_point,
                               radius_x, radius_y, inner_radius,
                               arc_start_pt, arc_end_pt,
                               start_angle, center_angle, options)
        end
      end

      # Draws a toroid.
      # @param [Element] canvas the element which the toroid is drawn on
      # @param [Coordinate] center_point the center point of the toroid
      # @param [Length] radius_x the x-axis radius of the toroid
      # @param [Length] radius_y the y-axis radius of the toroid
      # @param [#to_f] inner_radius the ratio of inner radius to the sector
      #   radius
      # @option (see #draw_line)
      # @return [Shape::Path] a drawn toroid
      # @raise [ArgumentError] _inner_radius_ is out of range
      # @since 1.1.0
      def draw_toroid(canvas, center_point, radius_x, radius_y, inner_radius, options={})
        if inner_radius >= 1 || 0 > inner_radius
          raise ArgumentError, "inner_radius is out of range: #{inner_radius}"
        end
        radius_x, radius_y = Length.new(radius_x).abs, Length.new(radius_y).abs
        center_point = Coordinate.new(center_point)
        arc_start_pt = center_point + [radius_x, 0]
        arc_opposite_pt = center_point - [radius_x, 0]
        inner_arc_start_pt = center_point + [radius_x * inner_radius, 0]
        inner_arc_opposite_pt = center_point - [radius_x * inner_radius, 0]

        draw_closed_path(canvas, arc_start_pt, options) {|path|
          path.arc_to(arc_opposite_pt, radius_x, radius_y, 0, true)
          path.arc_to(arc_start_pt, radius_x, radius_y, 0, true)
          path.close_path
          path.move_to(inner_arc_start_pt)
          path.arc_to(inner_arc_opposite_pt,
                      radius_x * inner_radius,
                      radius_y * inner_radius, 0, true, false)
          path.arc_to(inner_arc_start_pt,
                      radius_x * inner_radius,
                      radius_y * inner_radius, 0, true, false)
        }
      end

      # Draws a text.
      # @param [Element] canvas the element which the text is drawn on
      # @param [Coordinate] point the point of the base-line of the
      #   text. See _:text_anchor_ option
      # @param [String] text the drawn text string
      # @option (see #draw_line)
      # @option options [String] :text_anchor the way of aligning a string of
      #   text relative to _point_ argument. specifies one of the following
      #   vlaues: <tt>"start"</tt>, <tt>"middle"</tt>, <tt>"end"</tt>
      # @option options [Length] :text_length the length of the displayed text
      # @option options [String] :length_adjust the way of adjustments to make the
      #   rendered length of the text match _text_length_ option. specifies one
      #   of the following vlaues: <tt>"spacing"</tt>, <tt>"spacingAndGlyphs"</tt>
      # @option options [String] :text_decoration the decorations that are
      #   added to the text. specifies a string in a comma-separated combination
      #   of the following vlaues: <tt>"underline"</tt>, <tt>"overline"</tt>,
      #   <tt>"line-through"</tt>, <tt>"blink"</tt>
      # @option options [String] :writing_mode the inline-progression-direction
      #   for a text. specifies one of the following vlaues: <tt>"lr-tb"</tt>,
      #   <tt>"rl-tb"</tt>, <tt>"tb-rl"</tt>, <tt>"lr"</tt>, <tt>"rl"</tt>,
      #   <tt>"tb"</tt>
      # @option options [Boolean] :show_border whether the border is shown
      # @option options [Length] :border_rx the x-axis radius of the ellipse
      #   used to round off the corners of the rectangle when the rounded border
      #   is shown
      # @option options [Length] :vertical_padding the interval of vertical
      #   border line and text area
      # @option options [Length] :horizontal_padding the interval of horizontal
      #   border line and text area
      # @option options [Length] :border_ry the y-axis radius of the ellipse
      #   used to round off the corners of the rectangle when the rounded border
      #   is shown
      # @option options [Color, #write_as] :background_color the interior
      #   painting of the border-line when the border is shown
      # @option options [Color, #write_as] :border_color the painting along the
      #   border-line when the border is shown
      # @option options [Length] :border_width the width of border-line when the
      #   border is shown
      # @return [Shape::Text] a drawn text
      def draw_text(canvas, point, text, options={})
        Shape::Text.new(point, text, merge_option(options)).draw_on(canvas)
      end

      private

      def merge_option(options)
        {:painting=>@painting, :font=>@font}.merge(options)
      end

      # @since 1.1.0
      def draw_sector_internal(canvas, center_point,
                               radius_x, radius_y, inner_radius,
                               arc_start_pt, arc_end_pt,
                               start_angle, center_angle, merged_options)
        draw_closed_path(canvas, arc_start_pt, merged_options) {|path|
          path.arc_to(arc_end_pt, radius_x, radius_y, 0, (180 < center_angle))
          if inner_radius == 0
            path.line_to(center_point) if center_angle != 180
          else
            inner_arc_start_pt = center_point * (1 - inner_radius) + arc_end_pt * inner_radius
            inner_arc_end_pt = center_point * (1 - inner_radius) + arc_start_pt * inner_radius

            path.line_to(inner_arc_start_pt)
            path.arc_to(inner_arc_end_pt,
                        radius_x * inner_radius,
                        radius_y * inner_radius, 0, (180 < center_angle), false)
          end
        }
      end
    end

    # +Pen+ object holds a {Painting} object and a {Font} object. Using these
    # object, +Pen+ object creates instances of concrete subclass of
    # {Shape::Base}; a created instance has a painting attribute and a font
    # attribute that +Pen+ object holds.
    #
    # +Pen+ class has been optimized to draw a line or a outline of the shape.
    # Synonym methods of attributes _stroke_xxx_ has been defined in this class:
    # +color+(synonym of _stroke_), +dashoffset+(synonym of _stroke_dashoffset_),
    # +linecap+(synonym of _stroke_linecap_), +linejoin+(synonym of
    # _stroke_linejoin_), +miterlimit+(synonym of _stroke_miterlimit_) and
    # +width+(synonym of _stroke_width_).
    #
    # This class has shortcut contractors: _color_name_pen_, which a line color
    # is specified in.
    #
    # @example
    #   pen = DYI::Drawing::Pen.red_pen(:wdith => 3)
    #   # the followings is the same processing
    #   # pen = DYI::Drawing::Pen.new(:color => 'red', :wdith => 3)
    #   # pen = DYI::Drawing::Pen.new(:stroke => 'red', :stroke_wdith => 3)
    #   
    #   canvas = DYI::Canvas.new(100, 50)
    #   pen.draw_line(canvas, [10, 20], [90, 40])
    #
    # @since 0.0.0
    class Pen < PenBase

      # @private
      ALIAS_ATTRIBUTES =
        Painting::IMPLEMENT_ATTRIBUTES.inject({}) do |hash, key|
          hash[$'.empty? ? :color : $'.to_sym] = key if key.to_s =~ /^(stroke_|stroke$)/ && key != :stroke_opacity
          hash
        end

      # (see PenBase#initialize)
      # @option options [Color, #write_as] :color the value of attribute {#color
      #   color}
      # @option options [Array<Length>, String] :dasharray the value of
      #   attribute {#dasharray dasharray}
      # @option options [Length] :dashoffset the value of attribute {#dashoffset
      #   dashoffset}
      # @option options [String] :linecap the value of attribute {#linecap
      #   linecap}
      # @option options [String] :linejoin the value of attribute {#linejoin
      #   linejoin}
      # @option options [#to_f] :miterlimit the value of attribute {#miterlimit
      #   mitterlimit}
      # @option options [Lengthf] :width the value of attribute {#width width}
      def initialize(options={})
        options = options.clone
        ALIAS_ATTRIBUTES.each do |key, value|
          options[value] = options.delete(key) if options.key?(key) && !options.key?(value)
        end
        options[:stroke] = 'black' unless options.key?(:stroke)
        super
      end

      # @attribute color
      # Synonym of attribute {#stroke stroke}.
      # @return [Color, #write_as] the value of attribute stroke
      #+++
      # @attribute dasharray
      # Synonym of attribute {#stroke_dasharray stroke_dasharray}.
      # @return [Array<Length>] the value of attribute stroke_dasharray
      #+++
      # @attribute dashoffset
      # Synonym of attribute {#stroke_dashoffset stroke_dashoffset}.
      # @return [Length] the value of attribute stroke_dashoffset
      #+++
      # @attribute linecap
      # Synonym of attribute {#stroke_linecap stroke_linecap}.
      # @return [String] the value of attribute stroke_linecap
      #+++
      # @attribute linejoin
      # Synonym of attribute {#stroke_linejoin stroke_linejoin}.
      # @return [String] the value of attribute stroke_linejoin
      #+++
      # @attribute miterlimit
      # Synonym of attribute {#stroke_miterlimit stroke_miterlimit}.
      # @return [Float] the value of attribute stroke_mitterlimit
      #+++
      # @attribute width
      # Synonym of attribute {#stroke_width stroke_width}.
      # @return [Length] the value of attribute stroke_width
      ALIAS_ATTRIBUTES.each do |key, value|
        alias_method key, value
        alias_method "#{key}=", "#{value}="
      end

      # (see PenBase#draw_text)
      def draw_text(canvas, point, text, options={})
        painting = @painting
        text_painting = Painting.new(painting)
        text_painting.fill = painting.stroke
        text_painting.fill_opacity = painting.stroke_opacity
        text_painting.stroke = nil
        text_painting.stroke_width = nil
        @painting = text_painting
        shape = super
        @painting = painting
        shape
      end

      class << self
        def method_missing(method_name, *args, &block)
          if method_name.to_s =~ /^([a-z]+)_pen$/
            if options = args.first
              self.new(options.merge(:stroke => $1))
            else
              self.new(:stroke => $1)
            end
          else
            super
          end
        end
      end
    end

    # +Brush+ object holds a {Painting} object and a {Font} object. Using these
    # object, +Brush+ object creates instances of concrete subclass of
    # {Shape::Base}; a created instance has a painting attribute and a font
    # attribute that +Brush+ object holds.
    #
    # +Brush+ class has been optimized to fill a shape with a color and so on.
    # Synonym methods of attributes _fill_xxx_ has been defined in this class:
    # +color+(synonym of _fill_), +rule+(synonym of _fill_rule_).
    #
    # This class has shortcut contractors: _color_name_brush_, which a fill
    # color is specified in.
    #
    # @example
    #   brush = DYI::Drawing::Brush.red_brush
    #   # the followings is the same processing
    #   # brush = DYI::Drawing::Brush.new(:color => 'red')
    #   # brush = DYI::Drawing::Brush.new(:fill => 'red')
    #   
    #   canvas = DYI::Canvas.new(100, 50)
    #   brush.draw_ellipse(canvas, [50, 25], 40, 15)
    #
    # @since 0.0.0
    class Brush < PenBase

      # @private
      ALIAS_ATTRIBUTES =
        Painting::IMPLEMENT_ATTRIBUTES.inject({}) do |hash, key|
          hash[$'.empty? ? :color : $'.to_sym] = key if key.to_s =~ /^(fill_|fill$)/ && key != :fill_opacity
          hash
        end

      # (see PenBase#initialize)
      # @option options [Color, #write_as] :color the value of attribute {#color
      #   color}
      # @option options [String] :rule the value of attribute {#rule rule}
      def initialize(options={})
        options = options.clone
        ALIAS_ATTRIBUTES.each do |key, value|
          options[value] = options.delete(key) if options.key?(key) && !options.key?(value)
        end
        options[:stroke_width] = 0 unless options.key?(:stroke_width)
        options[:fill] = 'black' unless options.key?(:fill)
        super
      end

      # @attribute color
      # Synonym of attribute {#fill fill}.
      # @return [Color, #write_as] the value of attribute fill
      #+++
      # @attribute rule
      # Synonym of attribute {#fill_rule fill_rule}.
      # @return [String] the value of attribute fill_rule
      ALIAS_ATTRIBUTES.each do |key, value|
        alias_method key, value
        alias_method "#{key}=", "#{value}="
      end

      class << self
        def method_missing(method_name, *args, &block)
          if method_name.to_s =~ /([a-z]+)_brush/
            if options = args.first
              self.new(options.merge(:fill => $1))
            else
              self.new(:fill => $1)
            end
          else
            super
          end
        end
      end
    end
  end
end

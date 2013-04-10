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

    # This module defines the method to attach a marker symbol to the lines,
    # the polylines, the polygons or the paths.
    # @since 1.2.0
    module Markable

      # Returns a marker symbol at the specified position.
      # @param [Symbol] position the position where a marker symbol is drawn.
      #   Specifies the following values: +:start+, +:mid+, +:end+
      # @return [Marker] a marker symbol at the specified position
      def marker(position)
        @marker[position]
      end

      # Attaches a marker symbol to the shape.
      # @overload set_marker(position, marker)
      #   Attaches the specified marker symbol at the specified position.
      #   @param [Symbol] position the position where a marker symbol is drawn.
      #     Specifies the following values: +:start+, +:mid+, +:end+,
      #     +:start_end+, +:start_mid+, +:mid_end+, +:all+
      #   @param [Marker] marker the marker symbol that is attached
      # @overload set_marker(position, marker_type, options = {})
      #   Attaches a pre-defined marker symbol at the specified position.
      #   @param [Symbol] position the position where a marker symbol is drawn.
      #     Specifies the following values: +:start+, +:mid+, +:end+,
      #     +:start_end+, +:start_mid+, +:mid_end+, +:all+
      #   @param [Symbol] marker_type the type of pre-defined marker symbol that
      #     +:square+ is attached. Specifies the following values: +:circle+,
      #     +:triangle+, +:rhombus+, +:pentagon+, +:hexagon+
      #   @param [Hash] options a customizable set of options
      #   @option options [Number] :size size of the marker symbol. Specifies
      #     the relative size to line width
      #   @option options [Painting] :painting painting of the marker symbol
      #   @option options [Number, "auto"] :orient how the marker is rotated.
      #     Specifies a rotated angle or <tt>"auto"</tt>. <tt>"auto"</tt> means
      #     the marker symbol rotate the orientation of the line
      def set_marker(position, *args)
        pos = case position
                when :start then 0x1
                when :mid then 0x2
                when :end then 0x4
                when :start_mid then 0x3
                when :start_end then 0x5
                when :mid_end then 0x6
                when :all then 0x7
                else raise ArgumentError, "illegal argument: #{position.inspect}"
              end
        case args.first
        when Symbol
          opts = args[1].clone || {}
          opts[:painting] ||= Painting.new(:fill => painting.stroke,
                                           :fill_opacity => painting.stroke_opacity,
                                           :opacity => painting.opacity)
          if opts[:orient] == 'auto'
            opts[:direction] = position == :end ? :to_end : :to_start
          end
          marker = Marker.new(args.first, opts)
        when Marker
          marker = args.first
        else
          raise TypeError, "illegal argument: #{value}"
        end
        marker.set_canvas(canvas)
        @marker[:start] = marker if pos & 0x01 != 0
        @marker[:mid] = marker if pos & 0x02 != 0
        if pos & 0x04 != 0
          if pos & 0x01 != 0 && args.first.is_a?(Symbol) && opts[:orient] == 'auto'
            opts[:painting] ||= Painting.new(:fill => painting.stroke,
                                             :fill_opacity => painting.stroke_opacity,
                                             :opacity => painting.opacity)
            opts[:direction] = :to_end
            marker = Marker.new(args.first, opts)
            marker.set_canvas(canvas)
            @marker[:end] = marker
          else
            @marker[:end] = marker
          end
        end
      end

      # Returns whether this shape has a marker symbol.
      # @param [Symbol] position the position where a marker symbol is drawn.
      #   Specifies the following values: +:start+, +:mid+, +:end+
      # @return [Boolean] true if the shape has a marker at the cpecified point,
      #   false otherwise
      def has_marker?(position)
        !@marker[position].nil?
      end
    end

    # Base class of all graphical shapes.
    # @abstract
    # @since 0.0.0
    class Base < GraphicalElement

      # Returns painting status of the shape.
      attr_painting :painting

      # Returns font status of the shape.
      attr_font :font

      # Returns optional attributes of the shape.
      # @return [Hash] optional attributes
      attr_reader :attributes

      # Returns clipping status of the shape.
      # @return [Drawing::Clipping] clipping status
      attr_reader :clipping

      # Returns a parent element of the shape.
      # @return [GraphicalElement] a parent element
      # @since 1.0.0
      attr_reader :parent

      # Returns a location of a reference of a source anchor for the link.
      # @return [String] a location of a reference
      # @since 1.0.0
      attr_accessor :anchor_href

      # Returns a relevant presentation context when the link is activated.
      # @return [String] a relevant presentation context
      # @since 1.0.0
      attr_accessor :anchor_target

      # Draws the shape on a parent element.
      # @param [Element] parent a container element on which the shape is drawn
      # @return [Shape::Base] itself
      # @raise [ArgumentError] parent is nil
      # @raise [RuntimeError] this shape already has a parent, or descendants of
      #   this shape include itself
      def draw_on(parent)
        raise ArgumentError, "parent is nil" if parent.nil?
        return self if @parent == parent
        raise RuntimeError, "this shape already has a parent" if @parent
        current_node = parent
        loop do
          break if current_node.nil? || current_node.root_element?
          if current_node == self
            raise RuntimeError, "descendants of this shape include itself"
          end
          current_node = current_node.parent
        end
        (@parent = parent).child_elements.push(self)
        self
      end

      # @deprecated Use {#root_element?} instead.
      def root_node?
        msg = [__FILE__, __LINE__, ' waring']
        msg << ' DYI::Shape::Base#root_node? is depricated; use DYI::Shape::Base#root_element?'
        warn(msg.join(':'))
        false
      end

      # Returns whether this instance is root element of the shape.
      # @return [Boolean] always false.
      # @since 1.0.0
      def root_element?
        false
      end

      # Returns transform list.
      # @return [Array] transform list.
      def transform
        @transform ||= []
      end

      # Translates the shape.
      # @param [Numeric] x translated value along x-axis
      # @param [Numeric] y translated value along y-axis
      def translate(x, y=0)
        x = Length.new(x)
        y = Length.new(y)
        return if x.zero? && y.zero?
        lt = transform.last
        if lt && lt.first == :translate
          lt[1] += x
          lt[2] += y
          transform.pop if lt[1].zero? && lt[2].zero?
        else
          transform.push([:translate, x, y])
        end
      end

      # Scales up (or down) this shape.
      # @param [Numeric] x scaled ratio along x-axis
      # @param [Numeric] y scaled ratio along y-axis. If this parameter is nil,
      #   uses value that equals to parameter 'x' value
      # @param [Coordinate] base_point based coordinate of scaling up (or down)
      def scale(x, y=nil, base_point=Coordinate::ZERO)
        y ||= x
        return if x == 1 && y == 1
        base_point = Coordinate.new(base_point)
        translate(base_point.x, base_point.y) if base_point.nonzero?
        lt = transform.last
        if lt && lt.first == :scale
          lt[1] *= x
          lt[2] *= y
          transform.pop if lt[1] == 1 && lt[2] == 1
        else
          transform.push([:scale, x, y])
        end
        translate(- base_point.x, - base_point.y) if base_point.nonzero?
      end

      # Rotates this shape.
      # @param [Numeric] angle rotation angle. specifies degree
      # @param [Coordinate] base_point based coordinate of rotetion
      def rotate(angle, base_point=Coordinate::ZERO)
        angle %= 360
        return if angle == 0
        base_point = Coordinate.new(base_point)
        translate(base_point.x, base_point.y) if base_point.nonzero?
        lt = transform.last
        if lt && lt.first == :rotate
          lt[1] = (lt[1] + angle) % 360
          transform.pop if lt[1] == 0
        else
          transform.push([:rotate, angle])
        end
        translate(- base_point.x, - base_point.y) if base_point.nonzero?
      end

      # Skews this shape along x-axis.
      # @param [Numeric] angle skew angle. specifies degree
      # @param [Coordinate] base_point based coordinate of skew
      def skew_x(angle, base_point=Coordinate::ZERO)
        angle %= 180
        return if angle == 0
        base_point = Coordinate.new(base_point)
        translate(base_point.x, base_point.y) if base_point.nonzero?
        transform.push([:skewX, angle])
        translate(- base_point.x, - base_point.y) if base_point.nonzero?
      end

      # Skews this shape along y-axis.
      # @param [Numeric] angle skew angle. specifies degree
      # @param [Coordinate] base_point based coordinate of skew
      def skew_y(angle, base_point=Coordinate::ZERO)
        angle %= 180
        return if angle == 0
        base_point = Coordinate.new(base_point)
        translate(base_point.x, base_point.y) if base_point.nonzero?
        lt = transform.last
        transform.push([:skewY, angle])
        translate(- base_point.x, - base_point.y) if base_point.nonzero?
      end

      # Restricts the region to which paint can be applied.
      # @param [Drawing::Clipping] clipping a clipping object
      def set_clipping(clipping)
        clipping.set_canvas(canvas)
        @clipping = clipping
      end

      # Crears clipping settings.
      def clear_clipping
        @clipping = nil
      end

      # Sets shapes that is used to estrict the region to which paint can be
      #   applied.
      # @param [Base] shapes a shape that is used to clip
      def set_clipping_shapes(*shapes)
        set_clipping(Drawing::Clipping.new(*shapes))
      end

      # Returns whether this shape has a marker symbol.
      # @param [Symbol] position the position where a marker symbol is drawn.
      #   Specifies the following values: +:start+, +:mid+, +:end+
      # @return [Boolean] always false
      def has_marker?(position)
        return false
      end

      # Returns registed animations.
      # @return [Array<Animation::Base>] amination list.
      # since 1.0.0
      def animations
        @animations ||= []
      end

      # Returns whether the shape is animated.
      # @return [Boolean] true if the shape is animated, false otherwise
      # @since 1.0.0
      def animate?
        !(@animations.nil? || @animations.empty?)
      end

      # Adds animation to the shape
      # @param [Animation::Base] animation a animation that the shape is run
      # @since 1.0.0
      def add_animation(animation)
        animations << animation
      end

      # Adds animation of painting to the shape
      # @option options [Painting] :from the starting painting of the animation
      # @option options [Painting] :to the ending painting of the animation
      # @option options [Number] :duration a simple duration in seconds
      # @option options [Number] :begin_offset a offset that determine the
      #   animation begin, in seconds
      # @option options [Event] :begin_event an event that determine the
      #   animation begin
      # @option options [Number] :end_offset a offset that determine the
      #   animation end, in seconds
      # @option options [Event] :end_event an event that determine the animation
      #   end
      # @option options [String] :fill 'freeze' or 'remove'
      # @since 1.0.0
      def add_painting_animation(options)
        add_animation(Animation::PaintingAnimation.new(self, options))
      end

      # Adds animation of transform to the shape
      # @param [Symbol] type a type of transformation which is to have values
      # @option options [Number, Array] :from the starting transform of the
      #   animation
      # @option options [Number, Array] :to the ending transform of the animation
      # @option options [Number] :duration a simple duration in seconds
      # @option options [Number] :begin_offset a offset that determine the
      #   animation begin, in seconds
      # @option options [Event] :begin_event an event that determine the
      #   animation begin
      # @option options [Number] :end_offset a offset that determine the
      #   animation end, in seconds
      # @option options [Event] :end_event an event that determine the animation
      #   end
      # @option options [String] :fill 'freeze' or 'remove'
      # @since 1.0.0
      def add_transform_animation(type, options)
        add_animation(Animation::TransformAnimation.new(self, type, options))
      end

      # Adds animation of painting to the shape
      # @param [Event] an event that is set to the shape
      # @since 1.0.0
      def set_event(event)
        super
        canvas.set_event(event)
      end

      # Sets a location of a reference of a source anchor for the link.
      # @param [String] href a location of a reference
      # @since 1.0.0
      def anchor_href=(href)
        anchor_href = href.strip
        @anchor_href = anchor_href.empty? ? nil : anchor_href
      end

      # Returns whether the element has URI reference.
      # @return [Boolean] true if the element has URI reference, false otherwise
      # @since 1.0.0
      def has_uri_reference?
        @anchor_href ? true : false
      end

      private

      def init_attributes(options)
        options = options.clone
        @font = Font.new_or_nil(options.delete(:font))
        @painting = Painting.new_or_nil(options.delete(:painting))
        @anchor_href = options.delete(:anchor_href)
        @anchor_target = options.delete(:anchor_target)
        self.css_class = options.delete(:css_class)
        self.id = options.delete(:id) if options[:id]
        self.description = options.delete(:description) if options[:description]
        self.title = options.delete(:title) if options[:title]
        options
      end
    end

    # The rectangle in the vector image
    # @since 0.0.0
    class Rectangle < Base

      # Returns width of the rectangle.
      attr_length :width

      # Returns heigth of the rectangle.
      attr_length :height

      # @param [Coordinate] left_top a left-top coordinate of the rectangle
      # @param [Length] width width of the rectangle
      # @param [Length] heigth heigth of the rectangle
      # @option options [Painting] :painting painting status of this shape
      # @option options [Length] :rx the x-axis radius of the ellipse for
      #   rounded the rectangle
      # @option options [Length] :ry the y-axis radius of the ellipse for
      #   rounded the rectangle
      # @option options [String] :description the description of this shape
      # @option options [String] :title the title of this shape
      def initialize(left_top, width, height, options={})
        width = Length.new(width)
        height = Length.new(height)
        @lt_pt = Coordinate.new(left_top)
        @lt_pt += Coordinate.new(width, 0) if width < Length::ZERO
        @lt_pt += Coordinate.new(0, height) if height < Length::ZERO
        @width = width.abs
        @height = height.abs
        @attributes = init_attributes(options)
      end

      # Returns a x-axis coordinate of the left side of the rectangle.
      # @return [Length] the x-axis coordinate of the left side
      def left
        @lt_pt.x
      end

      # Returns a x-axis coordinate of the right side of the rectangle.
      # @return [Length] the x-axis coordinate of the right side
      def right
        @lt_pt.x + width
      end

      # Returns a y-axis coordinate of the top of the rectangle.
      # @return [Length] a y-axis coordinate of the top
      def top
        @lt_pt.y
      end

      # Returns a y-axis coordinate of the bottom of the rectangle.
      # @return [Length] a y-axis coordinate of the bottom
      def bottom
        @lt_pt.y + height
      end

      # Returns a coordinate of the center of the rectangle.
      # @return [Coordinate] a coordinate of the center
      def center
        @lt_pt + Coordinate.new(width.quo(2), height.quo(2))
      end

      # Writes the shape on io object.
      # @param [Formatter::Base] formatter an object that defines the image format
      # @param [IO] io an io to be written
      def write_as(formatter, io=$>)
        formatter.write_rectangle(self, io, &(block_given? ? Proc.new : nil))
      end

      class << self

        public

        # Create a new instance of Rectangle.
        # @param [Coordinate] left_top a coordinate of a corner of the rectangle
        # @param [Length] width width of the rectangle
        # @param [Length] heigth heigth of the rectangle
        # @option options [Painting] :painting painting status of the shape
        # @option options [Length] :rx the x-axis radius of the ellipse for
        #   rounded the rectangle
        # @option options [Length] :ry the y-axis radius of the ellipse for
        #   rounded the rectangle
        # @return [Rectangle] a new instance of Rectangle
        def create_on_width_height(left_top, width, height, options={})
          new(left_top, width, height, options)
        end

        # Create a new instance of Rectangle.
        # @param [Length] top a y-axis coordinate of the top
        # @param [Length] right a x-axis coordinate of the right side
        # @param [Length] bottom a y-axis coordinate of the bottom
        # @param [Length] left a x-axis coordinate of the left side
        # @option options [Painting] :painting painting status of the rectangle
        # @option options [Length] :rx the x-axis radius of the ellipse for
        #   rounded the rectangle
        # @option options [Length] :ry the y-axis radius of the ellipse for
        #   rounded the rectangle
        # @return [Rectangle] a new instance of Rectangle
        def create_on_corner(top, right, bottom, left, options={})
          left_top = Coordinate.new([left, right].min, [top, bottom].min)
          width = (Length.new(right) - Length.new(left)).abs
          height = (Length.new(bottom) - Length.new(top)).abs
          new(left_top, width, height, options)
        end
      end
    end

    # The circle in the vector image
    # @since 0.0.0
    class Circle < Base

      # Returns a center coordinate of the circle.
      attr_coordinate :center

      # Returns a radius of the circle.
      attr_length :radius

      # @param [Coordinate] center a center coordinate of the circle
      # @param [Length] radius a radius length of the circle
      # @option options [Painting] :painting painting status of this shape
      # @option options [String] :description the description of this shape
      # @option options [String] :title the title of this shape
      def initialize(center, radius, options={})
        @center = Coordinate.new(center)
        @radius = Length.new(radius).abs
        @attributes = init_attributes(options)
      end

      def left
        @center.x - @radius
      end

      def right
        @center.x + @radius
      end

      def top
        @center.y - @radius
      end

      def bottom
        @center.y + @radius
      end

      def width
        @radius * 2
      end

      def height
        @radius * 2
      end

      def write_as(formatter, io=$>)
        formatter.write_circle(self, io, &(block_given? ? Proc.new : nil))
      end

      class << self

        public

        def create_on_center_radius(center, radius, options={})
          new(center, radius, options)
        end
      end
    end

    class Ellipse < Base
      attr_coordinate :center
      attr_length :radius_x, :radius_y

      # @param [Coordinate] center a center coordinate of the ellipse
      # @param [Length] radius_x an x-axis radius of the ellipse
      # @param [Length] radius_y a y-axis radius of the ellipse
      # @option options [Painting] :painting painting status of this shape
      # @option options [String] :description the description of this shape
      # @option options [String] :title the title of this shape
      def initialize(center, radius_x, radius_y, options={})
        @center = Coordinate.new(center)
        @radius_x = Length.new(radius_x).abs
        @radius_y = Length.new(radius_y).abs
        @attributes = init_attributes(options)
      end

      def left
        @center.x - @radius_x
      end

      def right
        @center.x + @radius_x
      end

      def top
        @center.y - @radius_y
      end

      def bottom
        @center.y + @radius_y
      end

      def width
        @radius_x * 2
      end

      def height
        @radius_y * 2
      end

      def write_as(formatter, io=$>)
        formatter.write_ellipse(self, io, &(block_given? ? Proc.new : nil))
      end

      class << self

        public

        def create_on_center_radius(center, radius_x, radius_y, options={})
          new(center, radius_x, radius_y, options)
        end
      end
    end

    class Line < Base
      include Markable
      attr_coordinate :start_point, :end_point

      # @param [Coordinate] start_point a start coordinate of the line
      # @param [Coordinate] end_point an end coordinate of the line
      # @option options [Painting] :painting painting status of this shape
      # @option options [String] :description the description of this shape
      # @option options [String] :title the title of this shape
      def initialize(start_point, end_point, options={})
        @start_point = Coordinate.new(start_point)
        @end_point = Coordinate.new(end_point)
        @attributes = init_attributes(options)
        @marker = {}
      end

      def left
        [@start_point.x, @end_point.x].min
      end

      def right
        [@start_point.x, @end_point.x].max
      end

      def top
        [@start_point.y, @end_point.y].min
      end

      def bottom
        [@start_point.y, @end_point.y].max
      end

      def write_as(formatter, io=$>)
        formatter.write_line(self, io, &(block_given? ? Proc.new : nil))
      end

      class << self

        public

        def create_on_start_end(start_point, end_point, options={})
          new(start_point, end_point, options)
        end

        def create_on_direction(start_point, direction_x, direction_y, options={})
          start_point = Coordinate.new(start_point)
          end_point = start_point + Coordinate.new(direction_x, direction_y)
          new(start_point, end_point, options)
        end
      end
    end

    class Polyline < Base
      include Markable

      # @param [Coordinate] start_point a start coordinate of the shape
      # @option options [Painting] :painting painting status of this shape
      # @option options [String] :description the description of this shape
      # @option options [String] :title the title of this shape
      def initialize(start_point, options={})
        @points = [Coordinate.new(start_point)]
        @attributes = init_attributes(options)
        @marker = {}
      end

      def line_to(*points)
        @points.push(*points.map{|pt| Coordinate.new(pt)})
      end

      # @since 1.1.0
      def rline_to(*points)
        current = current_point
        @points.push(*points.inject([]){|result, pt| result << (current += pt)})
      end

      def current_point
        @points.last
      end

      def start_point
        @points.first
      end

      def points
        @points.clone
      end

      def undo
        @points.pop if @points.size > 1
      end

      def left
        @points.min {|a, b| a.x <=> b.x}.x
      end

      def right
        @points.max {|a, b| a.x <=> b.x}.x
      end

      def top
        @points.min {|a, b| a.y <=> b.y}.y
      end

      def bottom
        @points.max {|a, b| a.y <=> b.y}.y
      end

      def write_as(formatter, io=$>)
        formatter.write_polyline(self, io, &(block_given? ? Proc.new : nil))
      end
    end

    class Polygon < Polyline

      def write_as(formatter, io=$>)
        formatter.write_polygon(self, io, &(block_given? ? Proc.new : nil))
      end
    end

    # @since 1.0.0
    class Image < Rectangle
      attr_reader :file_path

      # @param [Coordinate] left_top a left-top coordinate of the image
      # @param [Length] width width of the image
      # @param [Length] heigth heigth of the image
      # @param [String] file_path a file path of the image
      # @option options [Painting] :painting painting status of this shape
      # @option options [String] :description the description of this shape
      # @option options [String] :title the title of this shape
      def initialize(left_top, width, height, file_path, options={})
        super(left_top, width, height, options)
        @file_path = file_path
      end

      # @return [Boolean] whether the element has a URI reference
      def has_uri_reference?
        true
      end

      def write_as(formatter, io=$>)
        formatter.write_image(self, io, &(block_given? ? Proc.new : nil))
      end
    end

    # @since 1.0.0
    class ImageReference < Image
      def include_external_file?
        true
      end
    end

    class Text < Base
      BASELINE_VALUES = ['baseline', 'top', 'middle', 'bottom']
      DEFAULT_LINE_HEIGHT = 1.0
      attr_coordinate :point
      attr_accessor :line_height
      attr_accessor :text
      attr_reader :format

      # @param [Coordinate] point a start coordinate of the text
      # @param [String] text a text that is displayed
      # @option options [Painting] :painting painting status of the shape
      # @option options [Font] :font font status of the text
      # @option options [String] :description the description of this shape
      # @option options [String] :title the title of this shape
      def initialize(point, text=nil, options={})
        @point = Coordinate.new(point || [0,0])
        @text = text
        @attributes = init_attributes(options)
      end

      def format=(value)
        @format = value && value.to_s
      end

      def font_height
        font.draw_size
      end

      def dy
        font_height * (line_height || DEFAULT_LINE_HEIGHT)
      end

      def formated_text
        if @format
          if @text.kind_of?(Numeric)
            @text.strfnum(@format)
          elsif @text.respond_to?(:strftime)
            @text.strftime(@format)
          else
            @text.to_s
          end
        else
          @text.to_s
        end
      end

      def write_as(formatter, io=$>)
        formatter.write_text(self, io, &(block_given? ? Proc.new : nil))
      end

      private

      def init_attributes(options)
        options = super
        format = options.delete(:format)
        @format = format && format.to_s
        line_height = options.delete(:line_height)
        @line_height = line_height || DEFAULT_LINE_HEIGHT
        options
      end
    end

    class ShapeGroup < Base
      attr_reader :child_elements

      # @option options [String] :description the description of this group
      # @option options [String] :title the title of this group
      def initialize(options={})
        @attributes = init_attributes(options)
        @child_elements = []
      end

      def width
        Length.new_or_nil(@attributes[:width])
      end

      def height
        Length.new_or_nil(@attributes[:height])
      end

      def write_as(formatter, io=$>)
        formatter.write_group(self, io, &(block_given? ? Proc.new : nil))
      end

      class << self
        public

        def draw_on(canvas, options = {})
          new(options).draw_on(canvas)
        end
      end
    end
  end
end

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

  # Class representing a coordinate. This class works with two length that mean
  # orthogonal coordinates. The initial coordinate system has the origin at the
  # top/left with the x-axis pointing to the right and the y-axis pointing down.
  #
  # The equality operator '{#== ==}' does not test equality instance but test
  # equality value of x-coordinate and y-coordinate.
  #
  # == Ways of Calculating
  #
  # This class suports following arithmetic operators and methods: {#+ +},
  # {#- -}, {#* *}, {#/ /}, {#** **}, {#quo}. The operators '{#+ +}', '{#- -}'
  # coerces a right hand operand into Coordinate, and then calculates.
  #
  # @since 0.0.0
  class Coordinate

    # @private
    @@default_format = '(x,y)'

    # Returns an x-coordinate
    # @return [Length] an x-coordinate
    attr_reader :x

    # Returns a y-coordinate
    # @return [Length] a y-coordinate
    attr_reader :y

    # @overload initialize(coordinate)
    #   Returns the argument itself.
    #   @param [Coordinate] coordinate the source coordinate
    # @overload initialize(array)
    #   Return a new instance of Coordinate. First element of _array_ is used
    #   for x-coordinate, second element of _array_ is used y-coordinate.
    #   @param [Array<Length, Number, String>] array an array converted into
    #     Coordinate
    #   @raise [ArgumentError] size of _array_ does not equal to 2
    # @overload initialize(x, y)
    #   @param [Length, Number, String] x an x-cooridnate
    #   @param [Length, Number, String] y a y-cooridnate
    # @raise [TypeError] the argument can not be coerced into +Coordinate+
    # @see .new
    def initialize(*args)
      case args.size
      when 1
        case arg = args.first
        when Coordinate
          @x = arg.x
          @y = arg.y
        when Array
          raise ArgumentError, "wrong number of arguments' size (#{arg.size} for 2)" if arg.size != 2
          @x = Length.new(arg[0])
          @y = Length.new(arg[1])
        else
          raise TypeError, "#{arg.class} can't be coerced into #{self.class}"
        end
      when 2
        @x = Length.new(args[0])
        @y = Length.new(args[1])
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for #{args.size == 0 ? 1 : 2})"
      end
    end

    # The origin point.
    ZERO = new(0,0)

    # Unary Plus -- Returns the receiver's value.
    # @return [Length] receiver itself
    def +@
      self
    end

    # Unary Minus -- Returns a coordinate whose x-coordinate and y-coordinate
    # negated.
    # @return [Length] the negated receiver's value
    def -@
      self.class.new(-@x, -@y)
    end

    # Returns a new coordinate which is the sum of the receiver and _other_.
    # First, _other_ is converted into +Coordinate+.
    # @param [Coordinate, Array<Length, Number, String>] other the value that
    #   can be converted into +Coordinate+
    # @return [Length] a new length which is the sum of the receiver and _other_
    def +(other)
      other = self.class.new(other)
      self.class.new(@x + other.x, @y + other.y)
    end

    # Returns a new length which is the difference of the receiver and _other_.
    # First _other_ is converted into +Coordinate+.
    # @param [Length, Numeric, String] other the value that can be converted
    #   into +Coordinate+
    # @return [Length] a new length which is the difference of the receiver and
    #   _other_
    def -(other)
      other = self.class.new(other)
      self.class.new(@x - other.x, @y - other.y)
    end

    # Returns a new muliplicative coordinate of the receiver by _number_.
    # @param [Numeric] number the operand value
    # @return [Length] a new muliplicative length
    def *(number)
      self.class.new(@x * number, @y * number)
    end

    # Raises a coordinate the _number_ power.
    # @param [Numeric] number the operand value
    # @return [Length] a coordinate the _number_ power
    def **(number)
      self.class.new(@x ** number, @y ** number)
    end

    # Returns a new divisional length of the receiver by _number_.
    # @param [Numeric] other the operand value
    # @return [Length] a new divisional length
    # @raise [TypeError] _other_ can't be coerced into Numeric
    def /(number)
      raise TypeError, "#{number.class} can't be coerced into Numeric" unless number.kind_of?(Numeric)
      self.class.new(@x.quo(number.to_f), @y.quo(number.to_f))
    end

    alias quo /

    # Returns whether the receiver is the origin point.
    # @return [Boolean] true if the receiver is the origin point, false
    #   otherwise
    def zero?
      @x.zero? && @y.zero?
    end

    # Returns whether the receiver is not the origin point.
    # @return [Coordinate, nil] self if the receiver is not the origin point,
    #   nil otherwise
    def nonzero?
      zero? ? nil : self
    end

    # Returns whether the receiver equals to _other_.
    # @param [Object] other an object
    # @return [Boolean] true if _other_ is an instance of +Coordinate+ and
    #   each coordinate of receiver equals to a coordinate of _other_, false
    #   otherwise
    def ==(other)
      return false unless other.kind_of?(self.class)
      @x == other.x && @y == other.y
    end

    # Returns a distance between receiver and the origin point.
    # @return [Length] a distance between receiver and the origin point
    def abs
      (@x ** 2 + @y ** 2) ** 0.5
    end

    # Returns a distance between receiver and _origin_.
    # @return [Length] a distance between receiver and _origin_
    def distance(other)
      (self - other).abs
    end

    # Returns a coordinate that converted into the user unit.
    # @return [Coordinate] a coordinate that converted into the user unit
    def to_user_unit
      self.class.new(@x.to_user_unit, @y.to_user_unit)
    end

    # Returns a string to represent the receiver.
    #
    # Format string can be specified for the argument. If no argument is given,
    # {.default_format} is used as format string. About format string, see the
    # documentation of {.default_format} method.
    # @param [String] format a format string
    # @return [Length] a string to represent the receiver
    # @example
    #   point = DYI::Coordinate.new(10, 20)
    #   point.to_s('<x, y>')         # => "<10, 20>"
    #   point.to_s('\\x:x, \\y:y')   # => "x:10, y:20"
    # @see .default_format=
    # @see .set_default_format
    def to_s(format=nil)
      fmts = (format || @@default_format).split('\\\\')
      fmts = fmts.map do |fmt|
        fmt.gsub(/(?!\\x)(.|\G)x/, '\\1' + @x.to_s).gsub(/(?!\\y)(.|\G)y/, '\\1' + @y.to_s).delete('\\')
      end
      fmts.join('\\')
    end

    # @private
    def inspect
      "(#{@x.inspect}, #{@y.inspect})"
    end

    class << self

      public

      # Creates and returns a new instance of Coordinate provided the argument
      # is not an instace of Coordinate. If the argument is an instace of
      # Coordinate, returns the argument itself.
      # @overload new(coordinate)
      #   Returns the argument itself.
      #   @param [Coordinate] coordinate the source coordinate
      # @overload new(array)
      #   Return a new instance of Coordinate. First element of _array_ is used
      #   for x-coordinate, second element of _array_ is used y-coordinate.
      #   @param [Array<Length, Number, String>] array an array converted into
      #     Coordinate
      #   @raise [ArgumentError] size of _array_ does not equal to 2
      # @overload new(x, y)
      #   @param [Length, Number, String] x an x-cooridnate
      #   @param [Length, Number, String] y a y-cooridnate
      # @raise (see #initialize)
      # @example
      #   x = DYI::Length(10)
      #   y = DYI::Length(20)
      #   point1 = DYI::Coordinate.new(x, y)              # this point is (10, 20)
      #   point2 = DYI::Coordinate.new(10, 20)            # it is (10, 20) too
      #   point3 = DYI::Coordinate.new([x, y])            # it is (10, 20) too
      #   point4 = DYI::Coordinate.new([10, 20])          # it is (10, 20) too
      #   point5 = DYI::Coordinate.new(['10px', '20px'])  # it is (10, 20) too
      def new(*args)
        return args.first if args.size == 1 && args.first.instance_of?(self)
        super
      end

      # Returns a new instace of Coordinate if the argments is not +nil+ (calls
      # +Coordinate.new+ method), but returns +nil+ if the argument is +nil+.
      # @return [Coordinate, nil] a new instace of Length if the argments is not
      #   nil, nil otherwise
      # @see .new
      def new_or_nil(*args)
        (args.size == 1 && args.first.nil?) ? nil : new(*args)
      end

      # Creates a new instance of Coordinate using the cartesian coordinates,
      # and returns it.
      # @param [Length, Number, String] x an x-cooridnate
      # @param [Length, Number, String] y a y-cooridnate
      def orthogonal_coordinates(x, y)
        new(x, y)
      end

      # Creates a new instance of Coordinate using the polar coordinates,
      # and returns it.
      # @param [Length, Number, String] radius distance from the origin point
      # @param [Numeric] theta the angle from x-direction in degrees
      def polar_coordinates(radius, theta)
        new(radius * DYI::Util.cos(theta), radius * DYI::Util.sin(theta))
      end

      # Invokes block with given format string as default format.
      # @overload set_default_format(format)
      #   Invokes block with given _format_ as default format. After invokes the
      #   block, the original format is used. 
      #   @param [String] format a format string
      #   @yield a block which the format string is used in
      #   @return [Length] the receiver itself
      # @overload set_default_format(format)
      #   Sets default format setring as {.default_format=} method.
      #   @param [String] format a format string
      #   @return [String] the given argument
      # @example
      #   # an initial format string is "(x,y)"
      #   point = DYI::Coordinate.new(10, 20)
      #   point.to_s                            # => "(10,20)"
      #   DYI::Coordinate.set_default_format('<x, y>') {
      #     point.to_s                          # => "<10, 20>"
      #     DYI::Length.set_default_format('0.0u') {
      #       point.to_s                        # => "<10.0pt, 20.0pt>"
      #     }
      #   }
      #   point.to_s                            # => "(10,20)"
      # @see Length.set_default_format
      # @see .default_format=
      def set_default_format(format)
        if block_given?
          org_format = default_format
          self.default_format = format
          yield
          self.default_format = org_format
          self
        else
          self.default_format = format
        end
      end

      # Returns a format that is used when called {#to_s} without an argument.
      # @return [String] a format string
      # @see .default_format=
      def default_format
        @@default_format
      end

      # Sets a format string that is used when called {#to_s} without an
      # argument. The format string that is set at this method is used
      # permanently. Use {.set_default_format} with a block when you want to use
      # a format string temporarily.
      #
      # Uses the following characters as coordinate format strings.
      # [<tt>"x"</tt> (x-coordinate placeholder)] Placeholder '+x+' is replaced
      #                                           as x-coordinate.
      # [<tt>"y"</tt> (y-coordinate placeholder)] Placeholder '+y+' is replaced
      #                                           as y-coordinate.
      # [<tt>"\\"</tt> (Escape Character)] Causes the next character to be
      #                                    interpreted as a literal.
      # @see #to_s
      # @see .set_default_format
      # @see Length.default_format=
      # @see Numeric#strfnum
      def default_format=(fromat)
        @@default_format = fromat.clone
      end
    end
  end
end

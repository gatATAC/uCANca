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

  # This class representing a length. Length object holds an amount and a unit.
  # The lists of unit identifiers matches the list of unit identifiers in CSS:
  # em, ex, px, pt, pc, cm, mm, in and percentages(%). When a unit is not given,
  # then the length is assumed to be in user units (i.e., a value in the current
  # user coordinate sytem).
  #
  # * As in CSS, the _em_ and _ex_ unit identifiers are relative to the current
  #   font's font-size and x-height, respectively.
  # * One _px_ unit is defined to be equal to one user unit.
  # * 1<em>pt</em> equals 1.25 user units.
  # * 1<em>pc</em> equals 15 user units.
  # * 1<em>mm</em> equals 3.543307 user units.
  # * 1<em>cm</em> equals 35.43307 user units.
  # * 1<em>in</em> equals 90 user units.
  # * For percentage values that are defined to be relative to the size of
  #   parent element.
  #
  # = Distuptive Change
  #
  # Length is not possible to change destructively. +#clone+ method and +#dup+
  # method raise TypeError.
  #
  # = Ways of Comparing and Calculating
  #
  # This class includes +Comparable+ module, therefore you can use the
  # comparative operators. In the comparison between DYI::Length objects, the
  # unit of each objects are arranged and it compares. The equality operator
  # '<tt>==</tt>' does not test equality instance but test equality value.
  #
  #   DYI::Length.new('1in') > DYI::Length.new(50)        # => true, 1in equals 90px.
  #   DYI::Length.new('1in') > DYI::Length.new('2em')     # => Error, 'em' is not comparable unit.
  #   DYI::Length.new('10cm') == DYI::Length.new('100mm') # => true
  #
  # This class suports following arithmetic operators and methods: {#+ +},
  # {#- -}, {#* *}, {#/ /}, {#% %}, {#** **}, {#div}, {#quo}, {#modulo}. The
  # operators '{#+ +}', '{#- -}' coerces a right hand operand into Length, and
  # then calculates.
  #
  # @since 0.0.0
  class Length
    include Comparable

    # Array of unit that can be used.
    UNITS = ['px', 'pt', '%', 'cm', 'mm', 'in', 'em', 'ex', 'pc']

    # @private
    @@units = {'px'=>1.0,'pt'=>1.25,'cm'=>35.43307,'mm'=>3.543307,'in'=>90.0,'pc'=>15.0}
    # @private
    @@default_format = '0.###U'

    # @overload initialize(length)
    #   Returns the argument itself.
    #   @param [Length] length the source length
    # @overload initialize(num)
    #   @param [Numeric] num the user unit value
    # @overload initialize(str)
    #   @param [String] str the string that mean the length
    # @raise [ArgumentError] the argument is a string that could not be understand
    # @raise [TypeError] the argument can not be coerced into Length
    # @see .new
    def initialize(length)
      case length
      when Length
        @value = length._num
        @unit = length._unit
      when Numeric
        @value = length
        @unit = nil
      when String
        unless /^\s*(-?[\d]*(?:\d\.|\.\d|\d)[0\d]*)(#{UNITS.join('|')})?\s*$/ =~ length
          raise ArgumentError, "`#{length}' is string that could not be understand"
        end
        __value, __unit = $1, $2
        @value = __value.include?('.') ? __value.to_f : __value.to_i
        @unit = (__unit == 'px' || @value == 0) ? nil : __unit
      else
        raise TypeError, "#{length.class} can't be coerced into Length"
      end
    end

    # Zero length.
    ZERO = new(0)

    # Unary Plus -- Returns the receiver's value.
    # @return [Length] receiver itself
    def +@
      self
    end

    # Unary Minus -- Returns the receiver's value, negated.
    # @return [Length] the negated receiver's value
    def -@
      new_length(-@value)
    end

    # Returns a new length which is the sum of the receiver and _other_. First,
    # _other_ is converted into +Length+.
    # @param [Length, Numeric, String] other the value that can be converted
    #   into +Length+
    # @return [Length] a new length which is the sum of the receiver and _other_
    def +(other)
      other = self.class.new(other)
      if @unit == other._unit
        new_length(@value + other._num)
      else
        self.class.new(to_f + other.to_f)
      end
    end

    # Returns a new length which is the difference of the receiver and _other_.
    # First _other_ is converted into +Length+.
    # @param [Length, Numeric, String] other the value that can be converted
    #   into +Length+
    # @return [Length] a new length which is the difference of the receiver and
    #   _other_
    def -(other)
      other = self.class.new(other)
      if @unit == other._unit
        new_length(@value - other._num)
      else
        self.class.new(to_f - other.to_f)
      end
    end

    # Returns a new muliplicative length of the receiver by _number_.
    # @param [Numeric] number the operand value
    # @return [Length] a new muliplicative length
    def *(number)
      new_length(@value * number)
    end

    # Raises a length the _number_ power.
    # @param [Numeric] number the operand value
    # @return [Length] a length the _number_ power
    def **(number)
      new_length(@value ** number)
    end

    # Returns a number which is the result of dividing the receiver by _other_.
    # @param [Length] other the operand length
    # @return [Number] a number which is the result of dividing
    # @raise [TypeError] _other_ can't be coerced into Length
    def div(other)
      case other
      when Length
        if @unit == other.unit
          @value.div(other._num)
        else
          to_f.div(other.to_f)
        end
      else
        raise TypeError, "#{other.class} can't be coerced into Length"
      end
    end

    # Return a number which is the modulo after division of the receiver by
    # _other_.
    # @param [Length] other the operand length
    # @return [Number] a number which is the modul
    # @raise [TypeError] _other_ can't be coerced into Length
    def % (other)
      case other
      when Length
        if @unit == other.unit
          new_length(@value % other._num)
        else
          self.class.new(to_f % other.to_f)
        end
      else
        raise TypeError, "#{other.class} can't be coerced into Length"
      end
    end

    # Divisional operator
    # @overload /(other)
    #   Returns a divisional float of the receiver by _other_.
    #   @param [Length] other the operand length
    #   @return [Float] a divisional value
    # @overload /(number)
    #   Returns a new divisional length of the receiver by _number_.
    #   @param [Numeric] other the operand value
    #   @return [Length] a new divisional length
    # @example
    #   DYI::Length.new(10) / 4                  # => 2.5px
    #   DYI::Length.new(10) / DYI::Length.new(4) # => 2.5
    # @raise [TypeError] the argument can't be coerced into Length or Numeric
    def /(number)
      case number
      when Numeric
        new_length(@value.quo(number.to_f))
      when Length
        if @unit == number.unit
          @value.quo(number._num.to_f)
        else
          to_f.quo(number.to_f)
        end
      else
        raise TypeError, "#{number.class} can't be coerced into Numeric or Length"
      end
    end

    alias quo /
    alias modulo %

    # @private
    def clone
      raise TypeError, "allocator undefined for Length"
    end

    # @private
    def dup
      raise TypeError, "allocator undefined for Length"
    end

    # Returns whether the receiver is a zero length.
    # @return [Boolean] true if the receiver is a zero length, false otherwise
    def zero?
      @value == 0
    end

    # Returns whether the receiver is a no-zero length.
    # @return [Length, nil] self if the receiver is not zero, nil otherwise
    def nonzero?
      @value == 0 ? nil : self
    end

    # Returns the absolute length of the receiver.
    # @return [Length] the absolute length
    def abs
      @value >= 0 ? self : -self
    end

    # Comparision -- compares two values. This is the basis for the tests in
    # +Comparable+.
    # @return [Fixnum, nil] +-1+, +0+, <tt>+1</tt> or +nil+ depending on whether
    #   the receiver is less than, equal to, greater than _other_; if is not
    #   comparable, +nil+.
    def <=>(other)
      return nil unless other.kind_of?(Length)
      if @unit == other._unit
        @value <=> other._num
      else
        to_f <=> other.to_f rescue nil
      end
    end

    # Returns the receiver's unit. If receiver has no unit, returns 'px'.
    # @return [String] the receiver's unit
    def unit
      @unit.nil? ? 'px' : @unit
    end

    # Invokes block with the sequence of length starting at receiver.
    # @overload step (limit, step)
    #   Invokes block with the sequence of length starting at receiver,
    #   incremented by _step_ on each call. The loop finishes when _length_ to
    #   be passed to the block is greater than _limit_ (if _step_ is positive)
    #   or less than _limit_ (if _step_ is negative).
    #   @param [Length] limit the limit of iteration continuation
    #   @param [Length] step an iteration interval
    #   @yield [len] an iteration block
    #   @yieldparam [Length] len the length that is created by stepping
    #   @return [Length] the receiver itself
    # @overload step (limit, step)
    #   Returns an enumerator instead of the iteration.
    #   @param [Length] limit the limit of iteration continuation
    #   @param [Length] step an iteration interval
    #   @return [Enumrator] an enumrator for stepping
    def step(limit, step)
      if @unit == limit._unit && @unit == step._unit
        self_value, limit_value, step_value = @value, limit._num, step._num
      else
        self_value, limit_value, step_value = to_f, limit.to_f, step.to_f
      end
      enum = Enumerator.new {|y|
        self_value.step(limit_value, step_value) do |value|
          self.new_length(value)
        end
      }
      if block_given?
        enum.each(&proc)
        self
      else
        enum
      end
    end

    # Returns a length that converted into length of user unit.
    # @return [Length] a length that converted into length of user unit
    def to_user_unit
      @unit ? self.class.new(to_f) : self
    end

    # Returns a string to represent the receiver.
    #
    # Format string can be specified for the argument. If no argument is given,
    # {.default_format} is used as format string. About format string, see the
    # documentation of {.default_format} method.
    # @param [String] format a format string
    # @return [Length] a string to represent the receiver
    # @example
    #   len1 = DYI::Length.new(1234.56)
    #   len1.to_s('0.#u')     # => "1234.6px"
    #   len1.to_s('0.#U')     # => "1234.6"
    #   len1.to_s('#,#0U')    # => "1,235"
    #   
    #   len2 = DYI::Length.new('10pt')
    #   len2.to_s('0u')       # => "10pt"
    #   len2.to_s('0U')       # => "10pt"
    # @see .default_format=
    # @see .set_default_format
    def to_s(format=nil)
      fmts = (format || @@default_format).split('\\\\')
      fmts = fmts.map do |fmt|
        fmt.gsub(/(?!\\U)(.|\G)U/, '\\1' + (@unit == '%' ? '\\%' : @unit.to_s)).gsub(/(?!\\u)(.|\G)u/, '\\1' + (@unit == '%' ? '\\%' : unit))
      end
      @value.strfnum(fmts.join('\\\\'))
    end

    # Returns amount part of the length converted into given unit as float. If
    # parameter +unit+ is given, converts into user unit.
    # @param [String] unit a unit converted into
    # @return [Float] amout part of the length
    # @raise [RuntimeError] length can not convert into other unit
    # @raise [ArgumentError] _unit_ is unknown unit
    def to_f(unit=nil)
      unless self_ratio = @unit ? @@units[@unit] : 1.0
        raise RuntimeError, "unit `#{@unit}' can not convert into user unit"
      end
      unless param_ratio = unit ? @@units[unit] : 1.0
        if UNITS.include?(unit)
          raise RuntimeError, "unit `#{@unit}' can not convert into user unit"
        else
          raise ArgumentError, "unit `#{@unit}' is unknown unit"
        end
      end
      (@value * self_ratio.quo(param_ratio)).to_f
    end

    # @private
    def inspect
      @value.to_s + @unit.to_s
    end

    protected

    def _num
      @value
    end

    def _unit
      @unit
    end

    private

    def new_length(value)
      other = self.class.allocate
      other.instance_variable_set(:@value, value)
      other.instance_variable_set(:@unit, @unit)
      other
    end

    class << self

      public

      # Creates and returns a new instance of Length provided the argument is
      # not an instace of Length. If the argument is an instace of Length,
      # returns the argument itself.
      # @overload new(length)
      #   Returns the argument itself.
      #   @param [Length] length the source length
      #   @return [Length] the argument itself
      # @overload new(num)
      #   @param [Numeric] num the user unit value
      # @overload new(str)
      #   @param [String] str the string that mean the length
      # @return [Length] an instace of Length
      # @raise (see #initialize)
      # @example
      #   length1 = DYI::Length.new(10)      # 10 user unit (equals to 10px)
      #   length2 = DYI::Length.new('10')    # it is 10px too
      #   length3 = DYI::Length.new('10px')  # it is 10px too
      def new(*args)
        return args.first if args.size == 1 && args.first.instance_of?(self)
        super
      end

      # Returns a new instace of Length if the argments is not +nil+ (calls
      # +Length.new+ method), but returns +nil+ if the argument is +nil+.
      # @return [Length, nil] a new instace of Length if the argments is not
      #   nil, nil otherwise
      # @see .new
      def new_or_nil(*args)
        (args.size == 1 && args.first.nil?) ? nil : new(*args)
      end

      # Returns a coefficient that is used for conversion from _unit_ into user
      # unit.
      # @param [String] unit a unit name
      # @return [Float] a coefficient that is used for conversion
      # @raise [ArgumentError] a given unit can not be converted into another
      #   unit
      def unit_ratio(unit)
        unless ratio = @@units[unit.to_s]
          raise ArgumentError, "unit `#{unit}' can not be converted into another unit"
        end
        ratio
      end

      # Invokes block with given format string as default format.
      # @overload set_default_format(format)
      #   Invokes block with given _format_ as default format. After invokes the
      #   block, the original format is used.
      #   @param [String] format a format string
      #   @yield a block which the format string is used in
      #   @return [Coordinate] the receiver itself
      # @overload set_default_format(format)
      #   Sets default format setring as {.default_format=} method.
      #   @param [String] format a format string
      #   @return [String] the given argument
      # @example
      #   # an initial format string is "#.###U"
      #   len = DYI::Length.new(1234.56)
      #   len.to_s                      # => "1234.56"
      #   DYI::Length.set_default_format('#,##0u') {
      #     len.to_s                    # => "1,235px"
      #   }
      #   len.to_s                      # => "1234.56"
      # @see .default_format=
      def set_default_format(format)
        if block_given?
          org_format = @@default_format
          self.default_format = format
          yield
          @@default_format = org_format
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

      # Sets a format string that is used when called {#to_s}. The format string
      # that is set at this method is used permanently. Use {.set_default_format}
      # with a block when you want to use a format string
      # temporarily.
      #
      # The format string is same as {Numeric#strfnum} format. In addition to
      # place-holder of {Numeric#strfnum}, following placeholder can be used.
      # [<tt>"u"</tt> (unit placeholder)] Placeholder '+u+' is replaced as a
      #                                   unit. If the unit is user unit, '+u+'
      #                                   is repleced as 'px'.
      # [<tt>"U"</tt> (unit placeholder)] Placeholder '+U+' is replaced as a
      #                                   unit. If the unit is user unit, '+U+'
      #                                   is replece as empty string.
      # [<tt>"\\"</tt> (Escape Character)] Causes the next character to be
      #                                    interpreted as a literal.
      # @see #to_s
      # @see .set_default_format
      # @see Numeric#strfnum
      def default_format=(fromat)
        @@default_format = fromat.clone
      end
    end
  end
end

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

  # @since 0.0.0
  class Color
    @@named_colors = {'aliceblue'=>[240,248,255],'antiquewhite'=>[250,235,215],'aqua'=>[0,255,255],'aquamarine'=>[127,255,212],'azure'=>[240,255,255],'beige'=>[245,245,220],'bisque'=>[255,228,196],'black'=>[0,0,0],'blanchedalmond'=>[255,235,205],'blue'=>[0,0,255],'blueviolet'=>[138,43,226],'brown'=>[165,42,42],'burlywood'=>[222,184,135],'cadetblue'=>[95,158,160],'chartreuse'=>[127,255,0],'chocolate'=>[210,105,30],'coral'=>[255,127,80],'cornflowerblue'=>[100,149,237],'cornsilk'=>[255,248,220],'crimson'=>[220,20,60],'cyan'=>[0,255,255],'darkblue'=>[0,0,139],'darkcyan'=>[0,139,139],'darkgoldenrod'=>[184,134,11],'darkgray'=>[169,169,169],'darkgreen'=>[0,100,0],'darkgrey'=>[169,169,169],'darkkhaki'=>[189,183,107],'darkmagenta'=>[139,0,139],'darkolivegreen'=>[85,107,47],'darkorange'=>[255,140,0],'darkorchid'=>[153,50,204],'darkred'=>[139,0,0],'darksalmon'=>[233,150,122],'darkseagreen'=>[143,188,143],'darkslateblue'=>[72,61,139],'darkslategray'=>[47,79,79],'darkslategrey'=>[47,79,79],'darkturquoise'=>[0,206,209],'darkviolet'=>[148,0,211],'deeppink'=>[255,20,147],'deepskyblue'=>[0,191,255],'dimgray'=>[105,105,105],'dimgrey'=>[105,105,105],'dodgerblue'=>[30,144,255],'firebrick'=>[178,34,34],'floralwhite'=>[255,250,240],'forestgreen'=>[34,139,34],'fuchsia'=>[255,0,255],'gainsboro'=>[220,220,220],'ghostwhite'=>[248,248,255],'gold'=>[255,215,0],'goldenrod'=>[218,165,32],'gray'=>[128,128,128],'grey'=>[128,128,128],'green'=>[0,128,0],'greenyellow'=>[173,255,47],'honeydew'=>[240,255,240],'hotpink'=>[255,105,180],'indianred'=>[205,92,92],'indigo'=>[75,0,130],'ivory'=>[255,255,240],'khaki'=>[240,230,140],'lavender'=>[230,230,250],'lavenderblush'=>[255,240,245],'lawngreen'=>[124,252,0],'lemonchiffon'=>[255,250,205],'lightblue'=>[173,216,230],'lightcoral'=>[240,128,128],'lightcyan'=>[224,255,255],'lightgoldenrodyellow'=>[250,250,210],'lightgray'=>[211,211,211],'lightgreen'=>[144,238,144],'lightgrey'=>[211,211,211],'lightpink'=>[255,182,193],'lightsalmon'=>[255,160,122],'lightseagreen'=>[32,178,170],'lightskyblue'=>[135,206,250],'lightslategray'=>[119,136,153],'lightslategrey'=>[119,136,153],'lightsteelblue'=>[176,196,222],'lightyellow'=>[255,255,224],'lime'=>[0,255,0],'limegreen'=>[50,205,50],'linen'=>[250,240,230],'magenta'=>[255,0,255],'maroon'=>[128,0,0],'mediumaquamarine'=>[102,205,170],'mediumblue'=>[0,0,205],'mediumorchid'=>[186,85,211],'mediumpurple'=>[147,112,219],'mediumseagreen'=>[60,179,113],'mediumslateblue'=>[123,104,238],'mediumspringgreen'=>[0,250,154],'mediumturquoise'=>[72,209,204],'mediumvioletred'=>[199,21,133],'midnightblue'=>[25,25,112],'mintcream'=>[245,255,250],'mistyrose'=>[255,228,225],'moccasin'=>[255,228,181],'navajowhite'=>[255,222,173],'navy'=>[0,0,128],'oldlace'=>[253,245,230],'olive'=>[128,128,0],'olivedrab'=>[107,142,35],'orange'=>[255,165,0],'orangered'=>[255,69,0],'orchid'=>[218,112,214],'palegoldenrod'=>[238,232,170],'palegreen'=>[152,251,152],'paleturquoise'=>[175,238,238],'palevioletred'=>[219,112,147],'papayawhip'=>[255,239,213],'peachpuff'=>[255,218,185],'peru'=>[205,133,63],'pink'=>[255,192,203],'plum'=>[221,160,221],'powderblue'=>[176,224,230],'purple'=>[128,0,128],'red'=>[255,0,0],'rosybrown'=>[188,143,143],'royalblue'=>[65,105,225],'saddlebrown'=>[139,69,19],'salmon'=>[250,128,114],'sandybrown'=>[244,164,96],'seagreen'=>[46,139,87],'seashell'=>[255,245,238],'sienna'=>[160,82,45],'silver'=>[192,192,192],'skyblue'=>[135,206,235],'slateblue'=>[106,90,205],'slategray'=>[112,128,144],'slategrey'=>[112,128,144],'snow'=>[255,250,250],'springgreen'=>[0,255,127],'steelblue'=>[70,130,180],'tan'=>[210,180,140],'teal'=>[0,128,128],'thistle'=>[216,191,216],'tomato'=>[255,99,71],'turquoise'=>[64,224,208],'violet'=>[238,130,238],'wheat'=>[245,222,179],'white'=>[255,255,255],'whitesmoke'=>[245,245,245],'yellow'=>[255,255,0],'yellowgreen'=>[154,205,50]}
    @@default_format = ['#%02X%02X%02X', false]
    attr_reader :name

    # :call-seq:
    # new (color_string)
    # new (rgb_array)
    # new (rgb_hash)
    # new (red, green, blue)
    # new (color)
    def initialize(*args)
      case args.size
        when 1 then color = args.first
        when 3 then color = args
        else raise ArgumentError, "wrong number of arguments (#{args.size} for #{args.size == 0 ? 1 : 3})"
      end

      case color
      when Color
        @r = color.red
        @g = color.green
        @b = color.blue
        @name = color.name
      when Array
        raise ArgumentError, "illegal size of Array: #{color.size}" if color.size != 3
        @r, @g, @b = color.map {|c| c.to_i & 0xff}
        @name = nil
      when Hash
        @r, @g, @b = [:r, :g, :b].map {|key| color[key].to_i & 0xff}
        @name = nil
      when String, Symbol
        color = color.to_s
        if color =~ /^\s*#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})\s*$/ # #ffffff
          @r, @g, @b = [$1, $2, $3].map {|s| s.hex}
          @name = nil
        elsif color =~ /^\s*#([0-9a-fA-F])([0-9a-fA-F])([0-9a-fA-F])\s*$/ # #fff
          @r, @g, @b = [$1, $2, $3].map {|s| (s * 2).hex}
          @name = nil
        elsif color =~ /^\s*rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)\s*$/ # rgb(255,255,255)
          @r, @g, @b = [$1, $2, $3].map {|s| s.to_i & 0xff}
          @name = nil
        elsif color =~ /^\s*rgb\s*\(\s*(\d+)%\s*,\s*(\d+)%\s*,\s*(\d+)%\s*\)\s*$/ # rgb(100%,100%,100%)
          @r, @g, @b = [$1, $2, $3].map {|s| (0xff * s.to_f / 100).to_i & 0xff}
          @name = nil
        else
          raise ArgumentError, "argument is empty" if color.size == 0
          raise ArgumentError, "`#{color}' is unknown color" unless rgb = @@named_colors[color.downcase]
          @r, @g, @b = rgb
          @name = color.downcase
        end
      else
        raise TypeError, "#{color.class} can't be coerced into #{self.class}"
      end
    end

    def ==(other)
      return false unless other.instance_of?(self.class)
      @r == other.red && @g == other.green && @b = other.blue
    end

    def eql?(other)
      return false unless self.class == other.class
      self == other
    end

    def hash
      (@r << 16) + (@g << 8) + @b 
    end

    def named?
      not @name.nil?
    end

    def red
      @r
    end

    def green
      @g
    end

    def blue
      @b
    end

    def r_red
      @r.quo(0.255).floor.quo(1000.0)
    end

    def r_green
      @g.quo(0.255).floor.quo(1000.0)
    end

    def r_blue
      @b.quo(0.255).floor.quo(1000.0)
    end

    def merge(other, ratio)
      raise ArgumentError, "ratio should be number between 0 and 1" if ratio < 0 || 1 < ratio
      other = self.class.new(other)
      r = @r * (1.0 - ratio) + other.red * ratio
      g = @g * (1.0 - ratio) + other.green * ratio
      b = @b * (1.0 - ratio) + other.blue * ratio
      self.class.new(r,g,b)
    end

    def color?
      true
    end

    # :call-seq:
    # to_s ()
    # to_s (fmt, disp_ratio=false)
    def to_s(*args)
      args[0] = self.class.check_format(args[0]) if args[0]
      args = @@default_format if args.empty?
      args[0] % (args[1] ? [r_red, r_green, r_blue] : [@r,@g,@b])
    end

    def to_s16(opacity=nil)
      opacity ? '#%02X%02X%02X%02X' % [0xff && (0xff * opacity), @r,@g,@b] : to_s('#%02X%02X%02X')
    end

    class << self

      public

      def new(*args)
        if args.size == 1
          case args.first
          when self
            return args.first
          when String, Symbol
            if color = named_color(args.first)
              return color
            end
          end
        end
        super
      end

      def new_or_nil(*args)
        (args.size == 1 && args.first.nil?) ? nil : new(*args)
      end

      def method_missing(name, *args)
        if args.size == 0 && color = named_color(name)
          instance_eval %{
            def self.#{name}
              @#{name}
            end
          }
          return color
        end
        super
      end

      def set_default_format(fmt, disp_ratio=false)
        org_format = @@default_format
        @@default_format = [check_format(fmt), disp_ratio]
        if block_given?
          yield
          @@default_format = org_format
        end
      end

      def default_format
        @@default_format
      end

      def check_format(fmt)
        begin
          (fmt = fmt.to_s) % [0.0, 0.0, 0.0]
          fmt
        rescue
          raise ArgumentError, "wrong format: `#{fmt}'"
        end
      end

      private

      def named_color(name)
        name = name.to_s.downcase
        color = instance_variable_get('@' + name) rescue (return nil)
        return color if color
        if @@named_colors[name]
          color = allocate
          color.__send__(:initialize, name)
          instance_variable_set('@' + name, color)
        end
      end
    end
  end
end

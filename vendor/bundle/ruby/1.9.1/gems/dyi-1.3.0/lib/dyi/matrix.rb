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

  # @since 1.0.0
  class Matrix
    attr_accessor :xx, :yx, :xy, :yy, :x0, :y0

    # :call-seq:
    # new (xx, yx, xy, yy, x0, y0)
    # 
    def initialize(*args)
      case args.first
      when :translate
        @xx = @yy = 1
        @xy = @yx = 0
        @x0 = args[1]
        @y0 = args[2] || 0
      when :scale
        @xx = args[1]
        @yy = args[2] || args[1]
        @xy = @yx = @x0 = @y0 = 0
      when :rotate
        @xx = @yy = DYI::Util.cos(args[1])
        @xy = -(@yx = DYI::Util.sin(args[1]))
        @x0 = @y0 = 0
      when :skewX
        @xx = @yy = 1
        @xy = DYI::Util.tan(args[1])
        @yx = @x0 = @y0 = 0
      when :skewY
        @xx = @yy = 1
        @yx = DYI::Util.tan(args[1])
        @xy = @x0 = @y0 = 0
      else
        raise ArgumentError unless args.size == 6
        @xx, @yx, @xy, @yy, @x0, @y0 = args
      end
    end

    def *(other)
      self.class.new(
        xx * other.xx + xy * other.yx,      yx * other.xx + yy * other.yx,
        xx * other.xy + xy * other.yy,      yx * other.xy + yy * other.yy,
        xx * other.x0 + xy * other.y0 + x0, yx * other.x0 + yy * other.y0 + y0)
    end

    def ==(other)
      xx == other.xx && yx == other.yx && xy == other.xy && yy == other.yy && x0 == other.x0 && y0 == other.y0
    end

    def translate(tx, ty)
      self * Matrix.translate(tx, ty)
    end

    def scale(sx, xy)
      self * Matrix.scale(sx, xy)
    end

    def rotate(angle)
      self * Matrix.rotate(angle)
    end

    def skew_x(angle)
      self * Matrix.skew_x(angle)
    end

    def skew_y(angle)
      self * Matrix.skew_y(angle)
    end

    def transform(coordinate)
      Coordinate.new(coordinate.x * @xx + coordinate.y * @xy + @x0, coordinate.x * @yx + coordinate.y * @yy + @y0)
    end

    class << self

      def identity
        new(1, 0, 0, 1, 0, 0)
      end

      def translate(tx, ty)
        new(:translate, tx, ty)
      end

      def scale(sx, sy)
        new(:scale, sx, sy)
      end

      def rotate(angle)
        new(:rotate, angle)
      end

      def skew_x(angle)
        new(:skewX, angle)
      end

      def skew_y(angle)
        new(:skewY, angle)
      end
    end
  end
end

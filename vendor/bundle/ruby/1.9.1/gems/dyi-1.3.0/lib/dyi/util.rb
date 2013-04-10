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

  # Defines the utility functions in this module.
  #
  # All the methods defined by the module are 'module functions', which are
  # called as private instance methods and are also called as public class
  # methods (they are methods of Math Module like).
  # See also {DYI::Script::EcmaScript::DomLevel2}.
  # @since 1.1.0
  module Util

    private

    # Converts the value of +degree+ from degrees to radians.
    # @param [Number] degree the value in degrees
    # @return [Float] the value in radians
    # @function
    def to_radian(degree)
      Math::PI * degree / 180
    end

    # Computes the sine of +degree+ (expressed in degrees).
    # @param [Number] degree the value in degrees
    # @return [Float] the sine of the parameter
    # @function
    def sin(degree)
      Math.sin(to_radian(degree))
    end

    # Computes the cosine of +degree+ (expressed in degrees).
    # @param [Number] degree the value in degrees
    # @return [Float] the cosine of the parameter
    # @function
    def cos(degree)
      Math.cos(to_radian(degree))
    end

    # Computes the tangent of +degree+ (expressed in degrees).
    # @param [Number] degree the value in degrees
    # @return [Float] the tangent of the parameter
    # @function
    def tan(degree)
      Math.tan(to_radian(degree))
    end

    # Computes the arc sine of +x+ in degrees. Returns -90 .. 90.
    # @param [Number] x
    # @return [Float] the arc sine value in degrees
    # @function
    def asin(x)
      Math.asin(x) * 180 / Math::PI
    end

    # Computes the arc cosine of +x+ in degrees. Returns 0 .. 180.
    # @param [Number] x
    # @return [Float] the arc cosine value in degrees
    # @function
    def acos(x)
      Math.acos(x) * 180 / Math::PI
    end

    # Computes the arc tangent of +x+ in degrees. Returns -90 .. 90.
    # @param [Number] x
    # @return [Float] the arc tanget value in degrees
    # @function
    def atan(x)
      Math.atan(x) * 180 / Math::PI
    end

    module_function(*private_instance_methods)
  end
end

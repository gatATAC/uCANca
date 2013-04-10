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

    # @since 0.0.0
    module Filter

      class DropShadow
        include DYI::SvgElement
        attr_reader :id

        def initialize(canvas, blur_std, dx, dy)
          @canvas = canvas
          @blur_std = blur_std.to_i
          @dx = Length.new(dx)
          @dy = Length.new(dy)
          @id = @canvas.add_define(self)
        end

        def child_elements
          []
        end

        def draw_children?
          true
        end

        private

        def attributes
          {
            :id => @id,
            :filterUnits => 'userSpaceOnUse',
            :x => 0,
            :y => 0,
            :width => @canvas.width,
            :height => @canvas.height,
          }
        end

        def svg_tag
           'filter'
        end

        def child_elements_to_svg(xml)
          xml.feGaussianBlur(:in => 'SourceAlpha', :stdDeviation => @blur_std, :result => 'blur')
          xml.feOffset(:in => 'blur', :dx => @dx, :dy => @dy,  :result => 'offsetBlur')
          xml.feMerge {
            xml.feMergeNode(:in => 'offsetBlur')
            xml.feMergeNode(:in => 'SourceGraphic')
          }
        end
      end
    end
  end
end

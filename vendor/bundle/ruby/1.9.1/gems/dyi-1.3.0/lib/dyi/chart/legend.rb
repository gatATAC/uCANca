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
  module Chart

    # @since 0.0.0
    module Legend

      private

      def draw_legend(names, shapes=nil, records=nil, colors=nil)
        legend_canvas.translate(legend_point.x, legend_point.y)
        if show_legend?
          pen = Drawing::Pen.black_pen(:font => legend_font)
          brush = Drawing::Brush.new
          names.each_with_index do |name, index|
            y = legend_font_size * (1.2 * (index + 1))
            group = Shape::ShapeGroup.draw_on(legend_canvas)
            case shapes && shapes[index]
            when Shape::Base
              shapes[index].draw_on(group)
            when NilClass
              brush.color = colors && colors[index] || chart_color(index)
              brush.draw_rectangle(
                group,
                Coordinate.new(legend_font_size * 0.2, y - legend_font_size * 0.8),
                legend_font_size * 0.8,
                legend_font_size * 0.8)
            end
            pen.draw_text(
              group,
              Coordinate.new(legend_font_size * 0.2 + legend_font_size, y),
              name)
          end
        end
      end

      def legend_font_size
        legend_font ? legend_font.draw_size : Font::DEFAULT_SIZE
      end

      def default_legend_point
        Coordinate.new(0,0)
      end

      def default_legend_format
        "{name}"
      end

      class << self

        private

        def included(klass)
          klass.__send__(:opt_accessor, :show_legend, :type => :boolean, :default => true)
          klass.__send__(:opt_accessor, :legend_font, :type => :font)
          klass.__send__(:opt_accessor, :legend_format, :type => :string, :default_method => :default_legend_format)
          klass.__send__(:opt_accessor, :legend_point, :type => :point, :default_method => :default_legend_point)
          klass.__send__(:opt_accessor, :legend_css_class, :type => :string)
        end
      end
    end
  end
end

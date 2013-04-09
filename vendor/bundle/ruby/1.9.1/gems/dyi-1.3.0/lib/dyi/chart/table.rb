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
    class Table < Base
      attr_reader :frame_canvas, :data_canvas

      def font
        @options[:font]
      end

      def font=(font)
        if font && !font.empty?
          @options[:font] = Font.new(font)
        else
          @options.delete(:font)
        end
        font
      end

      def row_height
        @options[:row_height] ||= (font && font.draw_size || Font::DEFAULT_SIZE) * 1.4
      end

      def row_height=(height)
        if heights
          @options[:row_height] = Length.new(height)
        else
          @options.delete(:row_height)
        end
        point
      end

      def column_widths
        @options[:column_widths]
      end

      def column_widths=(widths)
        if widths.kind_of?(Array)
          @options[:column_widths] = widths.map {|width| Length.new_or_nil(width)}
        elsif widths
          @options[:column_widths] = Length.new(widths)
        else
          @options.delete(:column_widths)
        end
        point
      end

      def column_width(index)
        case column_widths
          when Length then column_widths
          when Array then column_widths[index]
          else width / series.size
        end
      end

      def table_width
        series.inject(Length.new(0)) do |width, i|
          width + column_width(i)
        end
      end

      def table_height
        row_height * data[series.first].size
      end

      def horizontal_positions
        @options[:horizontal_positions]
      end

      def horizontal_positions=(positions)
        if positions && !positions.empty?
          @options[:horizontal_positions] = positions
        else
          @options.delete(:horizontal_positions)
        end
        positions
      end

      def horizontal_position(index)
        @options[:horizontal_positions] && @options[:horizontal_positions][index]
      end

      def column_colors
        @options[:column_colors]
      end

      def column_colors=(colors)
        if colors && !colors.empty?
          @options[:column_colors] = colors
        else
          @options.delete(:column_colors)
        end
        colors
      end
=begin
      def precedence_attribute
        @options[:precedence] || :column
      end

      def precedence=(row_or_column)
        case row_or_column.to_sym
          when :column then @options[:precedence] = :column
          when :row then @options[:precedence] = :row
          when nil, false then @options.delete(:precedence)
          else raise ArgumentError, "\"#{row_or_column}\" is invalid value"
        end
        row_or_column
      end
=end
      private

      def options
        @options
      end

      def default_csv_format
        [0, 1]
      end

      def convert_data(value)
        value.strip
      end

      def create_vector_image
        pen = Drawing::Pen.new
        @frame_canvas = Shape::ShapeGroup.draw_on(@canvas)
        @data_canvas = Shape::ShapeGroup.draw_on(@canvas)
        draw_frame(pen)
        draw_data(pen)
      end

      def draw_frame(pen)
        w = table_width
        h = table_height

        draw_column_colors

        pen.draw_rectangle(@frame_canvas, [0, 0], w, h)
        (1...data[series.first].size).each do |i|
          pen.draw_line(@frame_canvas, [0, row_height * i], [w, row_height * i])
        end
        series.inject(Length.new(0)) do |x, j|
          pen.draw_line(@frame_canvas, [x, 0], [x, h]) if x.nonzero?
          x + column_width(j)
        end
      end

      def draw_column_colors
        if column_colors
          brush = Drawing::Brush.new
          h = table_height

          series.inject(Length.new(0)) do |x, j|
            if column_colors[j]
              brush.color = Color.new(column_colors[j])
              brush.draw_rectangle(@frame_canvas, [x, 0], column_width(j), h)
              x + column_width(j)
            end
          end
        end
      end

      def draw_data(pen)
        cell_margin = (row_height - (font && font.draw_size || Font::DEFAULT_SIZE)) / 2
        series.inject(cell_margin) do |x, column_index|
          y = row_height - cell_margin
          data[column_index].each do |value|
            case horizontal_position(column_index)
              when 'middle' then pen.draw_text(@data_canvas, [x + column_width(column_index) / 2 - cell_margin, y], value, :text_anchor=>'middle')
              when 'end' then pen.draw_text(@data_canvas, [x + column_width(column_index) - cell_margin * 2, y], value, :text_anchor=>'end')
              else pen.draw_text(@data_canvas, [x, y], value)
            end
            y += row_height
          end
          x + column_width(column_index)
        end
      end
    end
  end
end

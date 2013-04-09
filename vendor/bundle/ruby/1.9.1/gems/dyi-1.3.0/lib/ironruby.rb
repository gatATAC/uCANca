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

require 'bigdecimal'
require 'mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
require 'System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
require 'System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
require 'Microsoft.VisualBasic, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'
require File.join(File.dirname(__FILE__), 'dyi/formatter/emf_formatter')


class BigDecimal < Numeric
  alias __org_div__ div
  def div(other)
    case other
      when BigDecimal then __org_div__(other)
      when Integer then __org_div__(BigDecimal.new(other.to_s))
      else to_f.div(other.to_f)
    end
  end
end

module DYI

  class Coordinate
    def to_cls_point
      System::Drawing::PointF.new(x.to_f, y.to_f)
    end
  end

  class Color
    def to_cls_color(opacity=nil)
      if opacity
        System::Drawing::Color.from_argb((opacity.to_f * 255).to_i, @r, @g, @b)
      else
        System::Drawing::Color.from_argb(@r, @g, @b)
      end
    end

    def create_cls_pen(opacity=nil)
      System::Drawing::Pen.new(to_cls_color(opacity))
    end

    def create_cls_brush(opacity=nil, shape=nil)
      System::Drawing::SolidBrush.new(to_cls_color(opacity))
    end
  end

  class Painting
    def cls_line_join
      case stroke_linejoin
        when 'miter' then System::Drawing::Drawing2D::LineJoin.miter
        when 'round' then System::Drawing::Drawing2D::LineJoin.round
        when 'bevel' then System::Drawing::Drawing2D::LineJoin.bevel
        else System::Drawing::Drawing2D::LineJoin.miter
      end
    end

    def cls_line_cap
      case stroke_linecap
        when 'butt' then System::Drawing::Drawing2D::LineCap.flat
        when 'round' then System::Drawing::Drawing2D::LineCap.round
        when 'square' then System::Drawing::Drawing2D::LineCap.square
        else System::Drawing::Drawing2D::LineCap.flat
      end
    end

    def cls_fill_mode
      case fill_rule
        when 'nonzero' then System::Drawing::Drawing2D::FillMode.winding
        when 'evenodd' then System::Drawing::Drawing2D::FillMode.alternate
        else System::Drawing::Drawing2D::FillMode.winding
      end
    end

    def cls_dash_pattern
      return nil if !stroke_dasharray || stroke_dasharray.size == 0
      pattern = System::Array[System::Single].new(stroke_dasharray.size)
      stroke_dasharray.each_with_index do |dash, i|
        pattern[i] = dash.to_f
      end
      pattern
    end

    def cls_pen
      return nil unless stroke && (stroke_width != DYI::Length::ZERO)
      pen = stroke.create_cls_pen(stroke_opacity)
      pen.width = stroke_width ? stroke_width.to_f : 1.0
      pen.start_cap = pen.end_cap = cls_line_cap
      pen.line_join = cls_line_join
      pen.dash_pattern = cls_dash_pattern if cls_dash_pattern
      pen
    end

    def cls_brush(shape)
      fill ? fill.create_cls_brush(fill_opacity, shape) : System::Drawing::SolidBrush.new(System::Drawing::Color.black)
    end
  end

  class Font
    def to_cls_font
      System::Drawing::Font.new(font_family || '', size ? size.to_f : DEFAULT_SIZE.to_f('pt'))
    end

    class << self
      def to_cls_font(font)
        font ? font.to_cls_font : System::Drawing::Font.new('', DEFAULT_SIZE.to_f('pt'))
      end
    end
  end

  class Matrix
    def to_cls_matrix
      System::Drawing::Drawing2D::Matrix.new(xx, yx, xy, yy, x0, y0)
    end
  end

  module Shape
    class Text < Base
      def string_format
        format = System::Drawing::StringFormat.new
        format.alignment =
          case attributes[:text_anchor]
            when 'start' then System::Drawing::StringAlignment.near
            when 'middle' then System::Drawing::StringAlignment.center
            when 'end' then System::Drawing::StringAlignment.far
            else System::Drawing::StringAlignment.near
          end
        format.line_alignment =
          case attributes[:alignment_baseline]
            when 'baseline' then System::Drawing::StringAlignment.far
            when 'top' then System::Drawing::StringAlignment.near
            when 'middle' then System::Drawing::StringAlignment.center
            when 'bottom' then System::Drawing::StringAlignment.far
            else System::Drawing::StringAlignment.far
          end
        format
      end
    end
  end

  class Canvas
    private
    def get_formatter(format=nil)
      case format
        when :svg, nil then Formatter::SvgFormatter.new(self, 2)
        when :xaml then Formatter::XamlFormatter.new(self, 2)
        when :eps then Formatter::EpsFormatter.new(self)
        when :emf then Formatter::EmfFormatter.new(self)     # added 'Windows Meta File'
        else raise ArgumentError, "`#{format}' is unknown format"
      end
    end
  end

  module Drawing
    module ColorEffect
      class LinearGradient
        def create_cls_brush(opacity=nil, shape=nil)
          brush = System::Drawing::Drawing2D::LinearGradientBrush.new(
              System::Drawing::PointF.new(
                  shape.left.to_f * (1.0 - start_point[0]) + shape.right.to_f * start_point[0],
                  shape.top.to_f * (1.0 - start_point[1]) + shape.bottom.to_f * start_point[1]),
              System::Drawing::PointF.new(
                  shape.left.to_f * (1.0 - stop_point[0]) + shape.right.to_f * stop_point[0],
                  shape.top.to_f * (1.0 - stop_point[1]) + shape.bottom.to_f * stop_point[1]),
              System::Drawing::Color.empty,
              System::Drawing::Color.empty)
          start_pad = end_pad = false
          if !spread_method || spread_method == 'pad'
            start_pad = (0.001 < @child_elements.first.offset && @child_elements.first.offset < 0.999)
            end_pad = (0.001 < @child_elements.last.offset && @child_elements.last.offset < 0.999)
          end
          color_count = @child_elements.size
          color_count += 1 if start_pad
          color_count += 1 if end_pad
          color_blend = System::Drawing::Drawing2D::ColorBlend.new(color_count)
          cls_colors = System::Array[System::Drawing::Color].new(color_count)
          positions = System::Array[System::Single].new(color_count)
          if start_pad
            gradient_stop = @child_elements.first
            cls_colors[0] = gradient_stop.color.to_cls_color(gradient_stop.opacity)
            positions[0] = 0.0
          end
          @child_elements.each_with_index do |gradient_stop, i|
            idx = start_pad ? i + 1 : i
            cls_colors[idx] = gradient_stop.color.to_cls_color(gradient_stop.opacity)
            positions[idx] = gradient_stop.offset.to_f
          end
          if end_pad
            gradient_stop = @child_elements.last
            cls_colors[color_count - 1] = gradient_stop.color.to_cls_color(gradient_stop.opacity)
            positions[color_count - 1] = 1.0
          end
          color_blend.colors = cls_colors
          color_blend.positions = positions
          brush.interpolation_colors = color_blend
          brush.wrap_mode = cls_wrap_mode
          brush
        end

        def cls_wrap_mode
          case spread_method
            when 'pad' then System::Drawing::Drawing2D::WrapMode.tile_flip_xy
            when 'reflect' then System::Drawing::Drawing2D::WrapMode.tile_flip_xy
            when 'repeat' then System::Drawing::Drawing2D::WrapMode.tile
            else System::Drawing::Drawing2D::WrapMode.tile_flip_xy
          end
        end
      end
    end
  end

  module Chart
    class CsvReader < ArrayReader
      def read(path, options={})
        options = options.dup
        @date_format = options.delete(:date_format)
        @datetime_format = options.delete(:datetime_format)

        encode = 
          case (options[:encode] || :utf8).to_sym
            when :utf8 then 'UTF-8'
            when :sjis then 'Shift_JIS'
            when :euc then 'EUC-JP'
            when :jis then 'iso-2022-jp'
            when :utf16 then 'UTF-16'
          end
        parser = Microsoft::VisualBasic::FileIO::TextFieldParser.new(
            path,
            System::Text::Encoding.get_encoding(encode))
        parser.set_delimiters(options[:col_sep] || ',')

        parsed_array = []
        while !parser.end_of_data
          parsed_array << parser.read_fields.map {|v| v.to_s}
        end
        super(parsed_array, options)
      end
    end

    class ExcelReader < ArrayReader
      def read(path, options={})
        if defined? WIN32OLE
          # for Windows
          path = WIN32OLE.new('Scripting.FileSystemObject').getAbsolutePathName(path)
          excel = WIN32OLE.new('Excel.Application')
          book = excel.workbooks.open(path)
          sheet = book.worksheets.item(options[:sheet] || 1)
          range = sheet.usedRange
          sheet_values = sheet.range(sheet.cells(1,1), sheet.cells(range.end(4).row, range.end(2).column)).value

          jagged_array = []
          sheet_values.get_length(0).times do |i|
            jagged_array << []
            sheet_values.get_length(1).times do |j|
              jagged_array[i] << sheet_values.get_value(i+1, j+1)
            end
          end
          sheet_values = jagged_array
        end

        begin
          super(sheet_values, options)
        ensure
          if defined? WIN32OLE
            book.close(false)
            excel.quit
            excel = sheet = nil
          end
          book = sheet_values = nil
          GC.start
        end
        self
      end
    end
  end

  module Formatter
    class EpsFormatter < Base
      def write_text(shape, io)
        command_block(io) {
          puts_line(io, '/GothicBBB-Medium-RKSJ-H findfont', shape.font.draw_size, 'scalefont setfont')
          text = String.new(
              System::Text::Encoding.convert(
                System::Text::Encoding.get_encoding('UTF-8'),
                System::Text::Encoding.get_encoding('Shift_JIS'),
                shape.formated_text
              )
            ).unpack('H*').first
#          text = NKF.nkf('-s -W', shape.formated_text).unpack('H*').first
          case shape.attributes[:text_anchor]
            when 'middle' then dx = "<#{text}> stringwidth pop -0.5 mul"
            when 'end' then dx = "<#{text}> stringwidth pop -1 mul"
            else dx = "0"
          end
          case shape.attributes[:alignment_baseline]
            when 'top' then y = shape.point.y - shape.font_height * 0.85
            when 'middle' then y = shape.point.y - shape.font_height * 0.35
            when 'bottom' then y = shape.point.y + shape.font_height * 0.15
            else y = shape.point.y
          end
          puts_line(io, "[ 1 0 0 -1 #{dx}", shape.point.y * 2, '] concat')
          puts_line(io, shape.point.x, y, 'moveto')
          puts_line(io, "<#{text}>", 'show')
        }
      end
    end
  end
end

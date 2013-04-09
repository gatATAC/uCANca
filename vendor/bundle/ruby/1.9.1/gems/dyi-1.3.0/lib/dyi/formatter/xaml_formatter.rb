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
  module Formatter

    # @since 0.0.0
    class XamlFormatter < XmlFormatter

      FONT_STYLE = {'normal'=>'Normal','italic'=>'Italic'}
      FONT_WEIGHT = {'normal'=>'Normal','bold'=>'Bold','100'=>'Thin','200'=>'ExtraLight','300'=>'Light','400'=>'Normal','500'=>'Medium','600'=>'SemiBold','700'=>'Bold','800'=>'ExtraBold','900'=>'Black'}
      FONT_STRETCH = {'normal'=>'Normal','ultra-condensed'=>'UltraCondensed','extra-condensed'=>'ExtraCondensed','condensed'=>'Condensed','semi-condensed'=>'SemiCondensed','semi-expanded'=>'SemiExpanded','expanded'=>'Expanded','extra-expanded'=>'ExtraExpanded','ultra-expanded'=>'UltraExpanded'}
      STROKE_LINE_CAP = {'butt'=>'Flat','round'=>'Round','square'=>'Square'}
      STROKE_LINE_JOIN = {'miter'=>'Miter','round'=>'Round','bevel'=>'Bevel'}
      TEXT_ANCHOR = {'start'=>'Left','middle'=>'Center','end'=>'Right'}
      SPREAD_METHOD = {'pad'=>'Pad','reflect'=>'Reflect','repeat'=>'Repeat'}

      def puts(io=$>)
        StringFormat.set_default_formats(:coordinate => 'x,y') {
          super
        }
      end

      def write_canvas(canvas, io)
        create_node(io, 'UserControl',
            :xmlns => "http://schemas.microsoft.com/winfx/2006/xaml/presentation",
            :"xmlns:x" => "http://schemas.microsoft.com/winfx/2006/xaml",
#            :"xmlns:navigation" => "clr-namespace:System.Windows.Controls;assembly=System.Windows.Controls.Navigation",
#            :"xmlns:d" => "http://schemas.microsoft.com/expression/blend/2008",
#            :"xmlns:mc" => "http://schemas.openxmlformats.org/markup-compatibility/2006",
            :Width => canvas.width,
            :Height => canvas.height) {
          create_node(io, 'Canvas'){
            canvas.child_elements.each do |element|
              element.write_as(self, io)
            end
          }
        }
      end

      def write_rectangle(shape, io)
        attrs, attr_creator = common_attributes(shape, :shape)
        attrs.merge!(:"Canvas.Left"=>shape.left, :"Canvas.Top"=>shape.top, :Width=>shape.width, :Height=>shape.height)
        attrs[:RadiusX] = shape.attributes[:rx] if shape.attributes[:rx]
        attrs[:RadiusY] = shape.attributes[:ry] if shape.attributes[:ry]
        if attr_creator
          create_node(io, 'Rectangle', attrs) {
            attr_creator.call(io, 'Rectangle')
          }
        else
          create_leaf_node(io, 'Rectangle', attrs)
        end
      end

      def write_circle(shape, io)
        attrs, attr_creator = common_attributes(shape, :shape)
        attrs.merge!(:"Canvas.Left"=>shape.center.x - shape.radius, :"Canvas.Top"=>shape.center.y - shape.radius, :Width=>shape.radius * 2, :Height=>shape.radius * 2)
        if attr_creator
          create_node(io, 'Ellipse', attrs) {
            attr_creator.call(io, 'Ellipse')
          }
        else
          create_leaf_node(io, 'Ellipse', attrs)
        end
      end

      def write_ellipse(shape, io)
        attrs, attr_creator = common_attributes(shape, :shape)
        attrs.merge!(:"Canvas.Left"=>shape.center.x - shape.radius_x, :"Canvas.Top"=>shape.center.y - shape.radius_y, :Width=>shape.radius_x * 2, :Height=>shape.radius_y * 2)
        if attr_creator
          create_node(io, 'Ellipse', attrs) {
            attr_creator.call(io, 'Ellipse')
          }
        else
          create_leaf_node(io, 'Ellipse', attrs)
        end
      end

      def write_line(shape, io)
        attrs, attr_creator = common_attributes(shape, :line)
        attrs.merge!(:X1 => shape.start_point.x, :Y1 => shape.start_point.y, :X2 => shape.end_point.x, :Y2 => shape.end_point.y)
        if attr_creator
          create_node(io, 'Line', attrs) {
            attr_creator.call(io, 'Line')
          }
        else
          create_leaf_node(io, 'Line', attrs)
        end
      end

      def write_polyline(shape, io)
        attrs, attr_creator = common_attributes(shape, :line)
        attrs.merge!(:Points => shape.points.join(' '))
        if attr_creator
          create_node(io, 'Polyline', attrs) {
            attr_creator.call(io, 'Polyline')
          }
        else
          create_leaf_node(io, 'Polyline', attrs)
        end
      end

      def write_polygon(shape, io)
        attrs, attr_creator = common_attributes(shape, :shape)
        attrs.merge!(:Points => shape.points.join(' '))
        if attr_creator
          create_node(io, 'Polygon', attrs) {
            attr_creator.call(io, 'Polygon')
          }
        else
          create_leaf_node(io, 'Polygon', attrs)
        end
      end

      def write_path(shape, io)
        attrs, attr_creator = common_attributes(shape, :line)
        attrs.merge!(:Data => shape.concise_path_data)
        if attr_creator
          create_node(io, 'Path', attrs) {
            attr_creator.call(io, 'Path')
          }
        else
          create_leaf_node(io, 'Path', attrs)
        end
      end

      def write_text(shape, io)
        attrs, attr_creator = common_attributes(shape, :text)
        attrs.merge!(:"Canvas.Left" => shape.point.x, :"Canvas.Top" => shape.point.y)
#        attrs[:"text-decoration"] = shape.attributes[:text_decoration] if shape.attributes[:text_decoration]
        case shape.attributes[:alignment_baseline]
          when nil then attrs[:"Canvas.Top"] -= shape.font_height * 0.85
          when 'middle' then attrs[:"Canvas.Top"] -= shape.font_height * 0.5
          when 'bottom' then attrs[:"Canvas.Top"] -= shape.font_height
        end
        case text_anchor = TEXT_ANCHOR[shape.attributes[:text_anchor]]
        when 'Left'
          attrs[:TextAlignment] = text_anchor
        when 'Center'
          attrs[:Width] = @canvas.width
          attrs[:"Canvas.Left"] -= @canvas.width.quo(2)
          attrs[:TextAlignment] = text_anchor
        when 'Right'
          attrs[:Width] = @canvas.width
          attrs[:"Canvas.Left"] -= @canvas.width
          attrs[:TextAlignment] = text_anchor
        end
#        attrs[:"writing-mode"] = shape.attributes[:writing_mode] if shape.attributes[:writing_mode]
        text = shape.formated_text
        if text =~ /(\r\n|\n|\r)/
          attrs[:Text] = $`.strip
          create_node(io, 'TextBlock', attrs) {
            attr_creator.call(io, 'TextBlock') if attr_creator
            create_leaf_node(io, 'LineBreak')
            $'.each_line do |line|
              create_leaf_node(io, 'Run', line.strip)
            end
          }
        else
          attrs[:Text] = text
          if attr_creator
            create_node(io, 'TextBlock', attrs, &attr_creator)
          else
            create_leaf_node(io, 'TextBlock', attrs)
          end
        end
      end

      def write_group(shape, io)
        attrs, attr_creator = common_attributes(shape)
        create_node(io, 'Canvas', attrs) {
          attr_creator.call(io, 'Canvas') if attr_creator
          create_node(io, 'Canvas.RenderTransform') {
            create_transform_node(shape, io)
          } unless shape.transform.empty?
          shape.child_elements.each do |element|
            element.write_as(self, io)
          end
        }
      end

      def write_linear_gradient(shape, io)
        attr = {
          :StartPoint => "#{shape.start_point[0]},#{shape.start_point[1]}",
          :EndPoint => "#{shape.stop_point[0]},#{shape.stop_point[1]}"}
        if spread_method = SPREAD_METHOD[shape.spread_method]
          attr[:SpreadMethod] = spread_method
        end
        create_node(io, 'LinearGradientBrush', attr) {
          shape.child_elements.each do |element|
            element.write_as(self, io)
          end
        }
      end

      def write_gradient_stop(shape, io)
        attrs = {:Offset=>shape.offset}
        attrs[:Color] = shape.color.to_s16(shape.opacity) if shape.color
        create_leaf_node(io, 'GradientStop', attrs)
      end

      def write_clip(shape, io)
        # TODO
      end

      private

      def common_attributes(shape, type=nil)
        attributes = {}
        font = create_font_attr(shape)
        painting, attr_creator = create_painting_attr(shape, type)
        attributes.merge!(font) unless font.empty?
        attributes.merge!(painting) unless painting.empty?
        [attributes, attr_creator]
      end

      def create_font_attr(shape)
        attr = {}
        if shape.respond_to?(:font) && (font = shape.font) && !font.empty?
          attr[:FontFamily] = font.font_family if font.font_family
          if font_style = FONT_STYLE[font.style]
            attr[:FontStyle] = font_style
          end
          if font_weight = FONT_WEIGHT[font.weight]
            attr[:FontWeight] = font_weight
          end
          if font_stretch = FONT_STRETCH[font.stretch]
            attr[:FontStretch] = font_stretch
          end
        end
        attr[:FontSize] = shape.font_height.to_user_unit if shape.respond_to?(:font_height)
        attr
      end

      def create_painting_attr(shape, type)
        attr = {}
        attr_creator = nil
        if shape.respond_to?(:painting) && (painting = shape.painting) && !painting.empty?
          if painting.fill
            if painting.fill.respond_to?(:write_as)
              case type
              when :shape,:line
                attr_creator = proc {|io, tag_name|
                  create_node(io, "#{tag_name}.Fill") {
                    painting.fill.write_as(self, io)
                  }
                }
              when :text
                attr_creator = proc {|io, tag_name|
                  create_node(io, "#{tag_name}.Foreground") {
                    painting.fill.write_as(self, io)
                  }
                }
              end
            else
              case type
                when :shape,:line then attr[:Fill] = painting.fill.to_s16(painting.fill_opacity)
                when :text then attr[:Foreground] = painting.fill.to_s16(painting.fill_opacity)
              end
            end
          end
          attr[:Stroke] = painting.stroke.to_s16(painting.stroke_opacity) if painting.stroke
          attr[:StrokeDashArray] = painting.stroke_dasharray.join(',') if painting.stroke_dasharray
          attr[:StrokeDashOffset] = painting.stroke_dashoffset.to_user_unit if painting.stroke_dashoffset
          if type == :line && linecap = STROKE_LINE_CAP[painting.stroke_linecap]
            attr[:StrokeStartLineCap] = linecap
            attr[:StrokeEndLineCap] = linecap
          end
          if linejoin = STROKE_LINE_JOIN[painting.stroke_linejoin]
            attr[:StrokeLineJoin] = linejoin
          end
          attr[:StrokeMiterLimit] = painting.stroke_miterlimit if painting.stroke_miterlimit
          if painting.stroke_width
            attr[:StrokeThickness] = painting.stroke_width.to_user_unit
          end
        end
        [attr, attr_creator]
      end

      def create_transform_node(shape, io)
        create_node(io, 'TransformGroup') {
          shape.transform.each do |tr|
            case tr.first
            when :translate
              create_leaf_node(io, 'TranslateTransform', :X=>tr[1], :Y=>tr[2])
            when :scale
              create_leaf_node(io, 'ScaleTransform', :ScaleX=>tr[1], :ScaleY=>tr[2])
            when :rotate
              create_leaf_node(io, 'RotateTransform', :Angle=>tr[1])
            when :skewX
              create_leaf_node(io, 'ScaleTransform', :AngleX=>tr[1])
            when :skewY
              create_leaf_node(io, 'ScaleTransform', :AngleY=>tr[1])
            end
          end
        }
      end
    end
  end
end

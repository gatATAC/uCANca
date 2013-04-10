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
    class LineChart < Base
      include AxisUtil
      include Legend
      CHART_TYPES = [:line, :area, :bar, :stackedbar]

      # @since 1.2.0
      DEFAULT_MARKERS = [:circle, :square, :triangle, :pentagon, :rhombus, :inverted_triangle]

      attr_reader :axis_back_canvas, :chart_back_canvas, :scale_canvas, :chart_front_canvas, :axis_front_canvas, :legend_canvas
      # @since 1.2.0
      attr_reader :x_scale_canvas, :y_scale_canvas, :guid_front_canvas, :chart_region
      # @since 1.3.0
      attr_reader :back_canvas, :data_label_canvas

      opt_accessor :chart_margins, {:type => :hash, :default => {}, :keys => [:top,:right,:bottom,:left], :item_type => :length}
      opt_accessor :chart_colors, {:type => :array, :item_type => :color}
      opt_accessor :chart_type, {:type => :symbol, :default => :line, :valid_values => CHART_TYPES}
      opt_accessor :chart_types, {:type => :array, :item_type => :symbol, :valid_values => CHART_TYPES.clone.unshift('')}
      opt_accessor :represent_3d, {:type => :boolean}
      opt_accessor :_3d_settings, {:type => :hash, :default => {}, :keys => [:background_opacity,:dx,:dy], :item_type => :float}
      opt_accessor :show_dropshadow, {:type => :boolean}
      opt_accessor :dropshadow_settings, {:type => :hash, :default => {}, :keys => [:blur_std,:dx,:dy], :item_type => :float}
      opt_accessor :x_axis_type, {:type => :symbol, :default => :range, :valid_values => [:point,:range]}
      opt_accessor :line_width, {:type => :integer}
      opt_accessor :bar_width_ratio, {:type => :float, :default => 0.6, :range => 0..1}
      opt_accessor :main_y_axis, {:type => :symbol, :default => :left, :valid_values => [:left,:right]}
      opt_accessor :axis_font, {:type => :font}
      opt_accessor :axis_settings, {:type => :hash, :default => {}, :keys => [:max, :min, :min_scale_value, :scale_count, :scale_interval], :item_type => :integer}
      opt_accessor :x_axis_format, {:type => :string}
      opt_accessor :axis_format, {:type => :string}
      opt_accessor :use_y_second_axises, {:type => :array, :item_type => :boolean}
      opt_accessor :second_axis_settings, {:type => :hash, :default => {}, :keys => [:max, :min], :item_type => :integer}
      opt_accessor :second_axis_format, {:type => :string, :default_method => :axis_format}
      opt_accessor :max_x_label_count, {:type => :integer, :default_proc => proc{|c| c.chart_width.div(Length.new(96))}}
      opt_accessor :show_x_labels, {:type => :boolean, :default => true}
      opt_accessor :legend_texts, {:type => :array, :item_type => :string}
      opt_accessor :use_effect, {:type => :boolean, :default => true}
      opt_accessor :bar_seriese_interval, {:type => :float, :default => 0.3}
      opt_accessor :color_columns, {:type => :array, :item_type => :integer}

      # Returns or sets whether to show marker on the line chart.
      # @since 1.2.0
      opt_accessor :show_markers, :type => :boolean

      # Returns or sets marker types on the line-chart.
      # @since 1.2.0
      opt_accessor :markers, {:type => :array, :item_type => :symbol}

      # Returns or sets a marker size on the line-chart.
      # @since 1.2.0
      opt_accessor :marker_size, {:type => :float, :default => 2.5}

      # @since 1.3.0
      opt_accessor :display_range, :type => :range, :default => (0..-1)

      # @since 1.3.0
      opt_accessor :show_data_label, :type => :boolean
      # @since 1.3.0
      opt_accessor :data_label_font, :type => :font
      # @since 1.3.0
      opt_accessor :data_label_format, :type => :string

      def margin_top
        chart_margins[:top] || Length.new(16)
      end

      def margin_right
        chart_margins[:right] || Length.new(64)
      end

      def margin_bottom
        chart_margins[:bottom] || Length.new(32)
      end

      def margin_left
        chart_margins[:left] || Length.new(64)
      end

      alias __org_chart_type__ chart_type

      def chart_type(index = nil)
        if index
          (chart_types && chart_types[index]) || __org_chart_type__
        else
          __org_chart_type__
        end
      end

      def s_3d_pen_options
        {:background_opacity => 0.3}.merge(_3d_settings)
      end

      def back_translate_value
        {
          :dx => (Length.new_or_nil(_3d_settings[:dx]) || Length.new(24)),
          :dy => (Length.new_or_nil(_3d_settings[:dy]) || Length.new(-8))
        }
      end

      def dropshadow_blur_std
        dropshadow_settings[:blur_std] || 4
      end

      def dropshadow_dx
        dropshadow_settings[:dx] || back_translate_value[:dx] / 2
      end

      def dropshadow_dy
        dropshadow_settings[:dy] || back_translate_value[:dy] / 2
      end

      def use_y_second_axis?(index = nil)
        if index
          use_y_second_axises && use_y_second_axises[index]
        else
          use_y_second_axises && use_y_second_axises.any?
        end
      end

      def chart_width
        width - margin_left - margin_right
      end

      def chart_height
        height - margin_top - margin_bottom
      end

      def line_chart_pen(color)
        if represent_3d?
          Drawing::CubicPen.new({:color => color, :width => line_width}.merge(s_3d_pen_options))
        else
          Drawing::Pen.new(:color => color, :width => line_width, :stroke_linecap => 'square')
        end
      end

      def bar_chart_brush(color, bar_width=nil)
        if represent_3d?
          bar_width ||= chart_width * bar_width_ratio / data.records_size
          Drawing::CylinderBrush.new(:color => color, :ry => bar_width * (back_translate_value[:dy] * bar_width_ratio).quo(back_translate_value[:dx] * 2))
        else
          Drawing::Brush.new(:color => color)
        end
      end

      def area_chart_brush(color)
        Drawing::Brush.new(:color => color)
      end

      # @since 1.1.0
      def initialize(*args)
        super
        init_container
      end

      private

      def default_legend_point
        Coordinate.new(margin_left, 0)
      end

      def create_vector_image
        super

        main_series_data = []
        sub_series_data = []
        @bar_series = []
        data.values_size.times do |i|
          main_series_data.push(*data.series(i)[display_range]) unless use_y_second_axis?(i)
          sub_series_data.push(*data.series(i)[display_range]) if use_y_second_axis?(i)
          @bar_series.push(i) if chart_type(i) == :bar
        end
        settings =
          moderate_axis(
            main_series_data,
            chart_height,
            axis_settings[:min],
            axis_settings[:max],
            axis_settings[:scale_count])
        sub_settings =
          moderate_sub_axis(
            sub_series_data,
            settings,
            second_axis_settings[:min],
            second_axis_settings[:max]) if use_y_second_axis?

        [:stackedbar, :bar, :area, :line].each do |chart_type|
          data.values_size.times do |i|
            if chart_type(i) == chart_type
              draw_chart(i, chart_type(i), chart_color(i), use_y_second_axis?(i) ? sub_settings : settings)
            end
          end
        end

        draw_axis(settings, sub_settings)
        texts = legend_texts # || data_columns.map{|i| data.column_title(i)}
        draw_legend(texts, legend_shapes)
      end

      def init_container
#        mask = Drawing::ColorEffect::Mask.new(@canvas)
#        mask.add_shapes(Shape::Rectangle.new(Drawing::Brush.new(:color => '#FFFFFF'), [margin_left, margin_top], chart_width, chart_height))
        @back_canvas = Shape::ShapeGroup.draw_on(@canvas)
        @axis_back_canvas = Shape::ShapeGroup.draw_on(@canvas)
#        @chart_front_canvas = Shape::ShapeGroup.draw_on(@canvas, :mask => "url(##{mask.id})") unless @chart_front_canvas
        chart_clip = Drawing::Clipping.new(Shape::Rectangle.new([margin_left, margin_top], width - margin_left - margin_right, height - margin_top - margin_bottom))
        @chart_region = Shape::Rectangle.new([margin_left, margin_top], width - margin_left - margin_right, height - margin_top - margin_bottom, :painting => {:stroke_width => 0})
        @chart_region.draw_on(canvas)
        unless @chart_back_canvas
          clip_container = Shape::ShapeGroup.draw_on(@canvas)
          @chart_back_canvas = Shape::ShapeGroup.draw_on(clip_container)
          clip_container.set_clipping(chart_clip)
        end
        @scale_canvas = Shape::ShapeGroup.draw_on(@canvas) unless @scale_canvas
        unless @chart_front_canvas
          clip_container = Shape::ShapeGroup.draw_on(@canvas)
          clip_container.set_clipping(chart_clip)
          @chart_front_canvas = Shape::ShapeGroup.draw_on(clip_container)
        end
        @guid_front_canvas = Shape::ShapeGroup.draw_on(@canvas)
        @guid_front_canvas.set_clipping(chart_clip)
        @data_label_canvas = Shape::ShapeGroup.draw_on(@canvas) unless @data_label_canvas
        @x_scale_canvas = Shape::ShapeGroup.draw_on(@canvas) unless @x_scale_canvas
        @y_scale_canvas = Shape::ShapeGroup.draw_on(@canvas) unless @y_scale_canvas
        @axis_front_canvas = Shape::ShapeGroup.draw_on(@canvas) unless @axis_front_canvas
        @legend_canvas = Shape::ShapeGroup.draw_on(@canvas) unless @legend_canvas
        @chart_options = {}
#        @chart_options[:filter] = "url(##{Drawing::Filter::DropShadow.new(@canvas, dropshadow_blur_std, dropshadow_dx, dropshadow_dy).id})" if show_dropshadow?
      end

      def draw_axis(settings, sub_settings)
        line_options = {:linecap => 'square'}
        line_pen = represent_3d? ? Drawing::CubicPen.new(line_options.merge(s_3d_pen_options)) : Drawing::Pen.new(line_options)
        sub_pen = represent_3d? ? Drawing::Pen.new : line_pen
        text_pen = Drawing::Pen.new(:font => axis_font)
        text_margin = axis_font && (axis_font.draw_size.quo(4)) || Font::DEFAULT_SIZE.quo(4)

        draw_y_axis(line_pen)
        draw_x_axis(line_pen, sub_pen, text_pen, text_margin)
        draw_scale(sub_pen, text_pen, settings, sub_settings, text_margin)
      end

      def draw_y_axis(pen)
        if use_y_second_axis? || main_y_axis == :left
          start_point = [margin_left, height - margin_bottom]
          end_point = [margin_left, margin_top]
          pen.draw_line(represent_3d? ? @axis_back_canvas : @axis_front_canvas, start_point, end_point)
        end

        if use_y_second_axis? || main_y_axis == :right
          start_point = [width - margin_right, height - margin_bottom]
          end_point = [width - margin_right, margin_top]
          pen.draw_line(@axis_front_canvas, start_point, end_point)
        end
      end

      def draw_scale(line_pen, text_pen, settings, sub_settings, text_margin)
        if settings[:min] == settings[:min_scale_value] - settings[:scale_interval]
          y = value_position_on_chart(margin_top, settings, settings[:min], true)
          if use_y_second_axis? || main_y_axis == :left
            text_pen.draw_text(
              @y_scale_canvas,
              [margin_left - text_margin, y],
              main_y_axis == :left ? settings[:min] : sub_settings[:min],
              :text_anchor=>'end',
              :format => (main_y_axis == :left ? axis_format : second_axis_format))
          end
          if use_y_second_axis? || main_y_axis == :right
            text_pen.draw_text(
              @y_scale_canvas,
              [width - margin_right + text_margin, y],
              main_y_axis == :right ? settings[:min] : sub_settings[:min],
              :format => (main_y_axis == :right ? axis_format : second_axis_format))
          end
        end

        if represent_3d? && (use_y_second_axis? || main_y_axis == :left)
          line_pen.draw_line(
            @axis_back_canvas,
            [margin_left, height - margin_bottom],
            [margin_left + back_translate_value[:dx], height - margin_bottom + back_translate_value[:dy]])
        end

        sub_axis_value = sub_settings[:min_scale_value] if use_y_second_axis?
        settings[:min_scale_value].step(settings[:max], settings[:scale_interval]) do |value|
          y = value_position_on_chart(margin_top, settings, value, true)

          if settings[:min] != value
            if represent_3d?
              if use_y_second_axis? || main_y_axis == :left
                draw_y_scale_line(
                  line_pen,
                  [margin_left, y],
                  [margin_left + back_translate_value[:dx], y + back_translate_value[:dy]])
              end
              draw_y_scale_line(
                line_pen,
                [margin_left + back_translate_value[:dx], y + back_translate_value[:dy]],
                [width - margin_right + back_translate_value[:dx], y + back_translate_value[:dy]])
              if use_y_second_axis? || main_y_axis == :right
                draw_y_scale_line(
                  line_pen,
                  [width - margin_right + back_translate_value[:dx], y + back_translate_value[:dy]],
                  [width - margin_right, y])
              end
            else
              line_pen.dasharray = '2,6'
              draw_y_scale_line(line_pen, [margin_left, y], [width - margin_right, y])
              line_pen.dasharray = nil
            end
          end

          if use_y_second_axis? || main_y_axis == :left
            text_pen.draw_text(
              @y_scale_canvas,
              [margin_left - text_margin, y],
              main_y_axis == :left ? value : sub_axis_value,
              :alignment_baseline=>'middle',
              :text_anchor=>'end',
              :font=>axis_font,
              :format => (main_y_axis == :left ? axis_format : second_axis_format))
          end

          if use_y_second_axis? || main_y_axis == :right
            text_pen.draw_text(
              @y_scale_canvas,
              [width - margin_right + text_margin, y],
              main_y_axis == :right ? value : sub_axis_value,
              :alignment_baseline=>'middle',
              :font=>axis_font,
              :format => (main_y_axis == :right ? axis_format : second_axis_format))
          end
          sub_axis_value += sub_settings[:scale_interval] if use_y_second_axis?
        end
      end

      def draw_y_scale_line(pen, left_point, right_point)
        pen.draw_line(@scale_canvas, left_point, right_point)
      end

      def needs_x_scale?(i, display_records_size)
        return true if display_records_size <= max_x_label_count
        i % ((display_records_size - 1) / [max_x_label_count - 1, 1].max) == 0
      end

      def draw_x_axis(main_pen, sub_pen, text_pen, text_margin)
        main_pen.draw_line(represent_3d? ? @axis_back_canvas : @axis_front_canvas, [margin_left, height - margin_bottom], [width - margin_right, height - margin_bottom])
        display_records_size = data.records[display_range].size
        non_display_size = display_range.begin + (display_range.begin >= 0 ? 0 : data.records_size)

        display_records_size.times do |i|
          next unless needs_x_scale?(i, display_records_size)
          text_x = order_position_on_chart(margin_left, chart_width, display_records_size, i, x_axis_type)
          scale_x = x_axis_type == :range ? order_position_on_chart(margin_left, chart_width, display_records_size + 1, i) : text_x
          text_pen.draw_text(
            @x_scale_canvas,
            [text_x, height - margin_bottom + text_margin],
            format_x_label(data.name_values[i + non_display_size]),
            :text_anchor => 'middle', :alignment_baseline => 'top') if show_x_labels?

          if x_axis_type == :point || display_records_size <= max_x_label_count
            sub_pen.draw_line_on_direction(
              @guid_front_canvas,
              [scale_x, height - margin_bottom],
              0,
              -(axis_font ? axis_font.draw_size : Font::DEFAULT_SIZE) * 0.5) if i > 0 && i < display_records_size - (x_axis_type == :range ? 0 : 1)
          end
        end
      end

      def draw_chart(id, chart_type, color, settings)
        case chart_type
          when :line then draw_line(id, color, settings)
          when :area then draw_area(id, color, settings)
          when :bar then draw_bar(id, color, settings)
          when :stackedbar then draw_stackedbar(id, color, settings)
        end
      end

      def draw_line(id, color, settings)
        values = data.series(id)
        return if values.compact.size == 0
        display_records_size = values[display_range].size
        non_display_size = display_range.begin + (display_range.begin >= 0 ? 0 : values.size)
        first_index = values.each_with_index {|value, i| break i if value}
        pen_options = {:color => color, :width => line_width}
        pen = line_chart_pen(color)

        x = order_position_on_chart(margin_left, chart_width, display_records_size, first_index - non_display_size, x_axis_type)
        y = value_position_on_chart(margin_top, settings, values[first_index], true)
        if show_data_label?
          label_pen = Drawing::Pen.black_pen(:font => data_label_font)
          font_size = label_pen.font ? label_pen.font.draw_size : Font::DEFAULT_SIZE
          label_pen.draw_text(data_label_canvas, [x, y - font_size * 0.25], data_label_format ? values[first_index].strfnum(data_label_format) : values[first_index].to_s, :text_anchor => 'middle')
        end
        pen.linejoin = 'bevel'
        polyline = pen.draw_polyline(@chart_front_canvas, [x, y], @chart_options) {|polyline|
                     ((first_index + 1)...values.size).each do |i|
                       x = order_position_on_chart(margin_left, chart_width, display_records_size, i - non_display_size, x_axis_type)
                       y = value_position_on_chart(margin_top, settings, values[i], true)
                       polyline.line_to([x, y])
                     end
                     if show_data_label?
                       label_pen.draw_text(data_label_canvas, [x, y - font_size * 0.25], data_label_format ? values[i].strfnum(data_label_format) : values[i].to_s, :text_anchor => 'middle')
                     end
                   }
        if show_markers?
          marker_type = (markers && markers[id % markers.size]) || DEFAULT_MARKERS[id % DEFAULT_MARKERS.size]
          polyline.set_marker(:all, marker_type, :size => marker_size)
        end
        pen.linejoin = 'bevel'
      end

      def draw_area(id, color, settings)
        values = data.series(id)
        return if values.compact.size == 0
        display_records_size = values[display_range].size
        non_display_size = display_range.begin + (display_range.begin >= 0 ? 0 : values.size)
        first_index = values.each_with_index {|value, i| break i if value}
        brush = area_chart_brush(color)

        x = order_position_on_chart(margin_left, chart_width, display_records_size, first_index - non_display_size, x_axis_type)
        y = value_position_on_chart(margin_top, settings, settings[:min], true)
        if show_data_label?
          label_pen = Drawing::Pen.black_pen(:font => data_label_font)
          font_size = label_pen.font ? label_pen.font.draw_size : Font::DEFAULT_SIZE
        end
        polygone = brush.draw_polygon(@chart_front_canvas, [x, y], @chart_options) {|polygon|
          (first_index...values.size).each do |i|
            x = order_position_on_chart(margin_left, chart_width, display_records_size, i - non_display_size, x_axis_type)
            y = value_position_on_chart(margin_top, settings, values[i], true)
            polygon.line_to([x, y])
            if show_data_label?
              label_pen.draw_text(data_label_canvas, [x, y - font_size * 0.25], data_label_format ? values[i].strfnum(data_label_format) : values[i].to_s, :text_anchor => 'middle')
            end
          end
          y = value_position_on_chart(margin_top, settings, settings[:min], true)
          polygon.line_to([x, y])
        }
        polygone.translate(back_translate_value[:dx], back_translate_value[:dy]) if represent_3d?
      end

      def draw_bar(id, color, settings)
        bar_group = Shape::ShapeGroup.new(@chart_options).draw_on(@chart_front_canvas)
        values = data.series(id)
        return if values.compact.size == 0
        display_records_size = values[display_range].size
        non_display_size = display_range.begin + (display_range.begin >= 0 ? 0 : values.size)
        bar_width = chart_width * bar_width_ratio / display_records_size / (@bar_series.size + (@bar_series.size - 1) * bar_seriese_interval)

        brush = bar_chart_brush(color, bar_width)

        if show_data_label?
          label_pen = Drawing::Pen.black_pen(:font => data_label_font)
          font_size = label_pen.font ? label_pen.font.draw_size : Font::DEFAULT_SIZE
        end
        values.each_with_index do |value, i|
          next if value.nil?
          x = order_position_on_chart(margin_left, chart_width, display_records_size, i - non_display_size, x_axis_type, bar_width_ratio) + bar_width * (1 + bar_seriese_interval) * @bar_series.index(id)
          y = value_position_on_chart(margin_top, settings, value, true)
          brush = bar_chart_brush(data.has_field?(:color) ? data.records[i].color : color, bar_width) if data.has_field?(:color)
          brush.draw_rectangle(bar_group, [x, y], bar_width, height - margin_bottom - y)
          if show_data_label?
            label_pen.draw_text(data_label_canvas, [x + bar_width * 0.5, y - font_size * 0.4], data_label_format ? value.strfnum(data_label_format) : value.to_s, :text_anchor => 'middle')
          end
        end
        bar_group.translate(back_translate_value[:dx] / 2, back_translate_value[:dy] / 2) if represent_3d?
      end

      def draw_stackedbar(id, color, settings)
        bar_group = Shape::ShapeGroup.new(@chart_options).draw_on(@chart_front_canvas)

        values = data.series(id)
        return if values.compact.size == 0
        display_records_size = values[display_range].size
        non_display_size = display_range.begin + (display_range.begin >= 0 ? 0 : values.size)
        bar_width = chart_width * bar_width_ratio / display_records_size

        brush = bar_chart_brush(color, bar_width)

        @stacked_values ||= []

        values.each_with_index do |value, i|
          @stacked_values[i] ||= 0
          next if value.nil?
          x = order_position_on_chart(margin_left, chart_width, display_records_size, i - non_display_size, x_axis_type, bar_width_ratio)
          y = value_position_on_chart(margin_top, settings, (@stacked_values[i] += value), true)
          bar_height = value_position_on_chart(margin_top, settings, (@stacked_values[i] - value), true) - y
#          brush.color = data[:$color][i] if data[:$color]
          brush.draw_rectangle(bar_group, [x, y], bar_width,  bar_height)
        end
        bar_group.translate(back_translate_value[:dx] / 2, back_translate_value[:dy] / 2) if represent_3d?
      end

      # @since 1.0.0
      def chart_color(index)
        if chart_colors
          color = chart_colors[index]
        end
        color || DEFAULT_CHART_COLOR[index % DEFAULT_CHART_COLOR.size]
      end

      def legend_shapes
        result = []
        (0...data.values_size).each_with_index do |id, index|
          result <<
            case chart_type(index)
            when :line, nil
              Shape::Line.create_on_start_end(
                [legend_font_size * 0.2, legend_font_size * (1.2 * index + 0.8)],
                [legend_font_size, legend_font_size * (1.2 * index + 0.8)],
                :painting => {:stroke => chart_color(index), :stroke_width => line_width})
            when :bar, :stackedbar
              nil
            when :area
              nil
            else
              nil
            end
        end
        result
      end

      def format_x_label(obj)
        if x_axis_format
          if obj.kind_of?(Numeric)
            obj.strfnum(x_axis_format)
          elsif obj.respond_to?(:strftime)
            obj.strftime(x_axis_format)
          else
            obj.to_s
          end
        else
          obj.to_s
        end
      end
    end
  end
end

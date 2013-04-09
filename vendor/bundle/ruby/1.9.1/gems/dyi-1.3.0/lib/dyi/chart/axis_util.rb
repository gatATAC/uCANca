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

require 'csv'

module DYI
  module Chart

    # @since 0.0.0
    module AxisUtil

      private

      def moderate_axis(data, axis_length, min=nil, max=nil, scale_count_limit=nil)
        raise ArgumentError, 'no data' if (data = data.flatten.compact).empty?

        axis_length = Length.new(axis_length)
        data_min, data_max = chart_range(data, min, max)

        base_value = base_value(data_min, data_max, min.nil?, max.nil?)
        scale_count_limit ||= (axis_length / Length.new(30)).to_i
        scale_count_limit = 10 if 10 < scale_count_limit
        scale_count_limit = 2 if scale_count_limit < 2
        scale_interval = scale_interval(base_value, data_min, data_max, scale_count_limit)
        min_scale_value = nil
        (base_value + scale_interval).step(data_min, -scale_interval) {|n| min_scale_value = n}
        min ||= (min_scale_value.nil? ? base_value : min_scale_value - scale_interval)
        min_scale_value ||= min + scale_interval
        unless max
          base_value.step(data_max, scale_interval) {|n| max = n}
          max += scale_interval if max < data_max
        end
        {
          :min => min || min_scale_value - scale_interval,
          :max => max,
          :axis_length => axis_length,
          :min_scale_value => min_scale_value,
          :scale_interval => scale_interval
        }
      end

      def top_digit(num, n=1)
        num.div(10 ** (figures_count(num) - n + 1))
      end

      def suitable_1digit_value(a, b)
        return a if a == b
        a, b = b, a if a > b
        return 0 if a == 0
        return 5 if a <= 5 && 5 <= b
        return 2 if a <= 2 && 2 <= b
        return 4 if a <= 4 && 4 <= b
        return 6 if a <= 6 && 6 <= b
        8
      end

      def figures_count(num)
        Math.log10(num).floor
      end

      def base_value(a, b, allow_under=true, allow_over=true)
        return 0 if a * b <= 0 || a == b
        a, b = -a, -b if negative = (a < 0)
        a, b = b, a if a > b
        return 0 if ((negative && allow_over) || (!negative && allow_under)) &&  a < b * 0.3 
        suitable_value_positive(a, b) * (negative ? -1 : 1)
      end

      def suitable_value_positive(a, b)
        if figures_count(a) != (dig = figures_count(b))
          return 10 ** dig
        end
        n = 1
        n += 1 while (dig_a = top_digit(a, n)) == (dig_b = top_digit(b, n))
        (suitable_1digit_value(dig_a - dig_a.div(10) * 10 + (dig_a == dig_a.div(10) * 10 ? 0 : 1), dig_b - dig_b.div(10) * 10) + dig_a.div(10) * 10) * (10 ** (dig - figures_count(dig_a)))
      end

      def scale_interval(base_value, data_min, data_max, scale_count_limit)
        if base_value - data_min < data_max - base_value
          allocate_scale_count = (data_max - base_value).div((data_max - data_min).quo(scale_count_limit))
          scale_interval_base2edge(base_value, data_max, allocate_scale_count)
        else
          allocate_scale_count = (base_value - data_min).div((data_max - data_min).quo(scale_count_limit))
          scale_interval_base2edge(base_value, data_min, allocate_scale_count)
        end
      end

      def scale_interval_base2edge(base_value, edge_value, scale_count_limit)
        raise ArgumentError, 'base_value should not equal edge_value' if edge_value == base_value
        range = (base_value - edge_value).abs

        top_2_digits = top_digit(range, 2)
        case scale_count_limit.to_i
          when 1
            case top_2_digits
              when 10 then label_range = 10
              when 11..20 then label_range = 20
              when 21..40 then label_range = 40
              when 41..50 then label_range = 50
              when 51..99 then label_range = 100
            end
          when 2
            case top_2_digits
              when 10 then label_range = 5
              when 11..20 then label_range = 10
              when 21..40 then label_range = 20
              when 41..50 then label_range = 25
              when 51..99 then label_range = 50
            end
          when 3
            case top_2_digits
              when 10 then label_range = 4
              when 11..15 then label_range = 5
              when 16..30 then label_range = 10
              when 31..60 then label_range = 20
              when 61..75 then label_range = 25
              when 76..99 then label_range = 40
            end
          when 4
            case top_2_digits
              when 10 then label_range = 2.5
              when 11..15 then label_range = 4
              when 16..20 then label_range = 5
              when 21..40 then label_range = 10
              when 41..80 then label_range = 20
              when 81..99 then label_range = 25
            end
          when 5
            case top_2_digits
              when 10 then label_range = 2
              when 11..12 then label_range = 2.5
              when 13..15 then label_range = 4
              when 16..25 then label_range = 5
              when 26..50 then label_range = 10
              when 51..99 then label_range = 20
            end
          when 6
            case top_2_digits
              when 10..12 then label_range = 2
              when 13..15 then label_range = 2.5
              when 16..20 then label_range = 4
              when 21..30 then label_range = 5
              when 31..60 then label_range = 10
              when 61..99 then label_range = 20
            end
          when 7
            case top_2_digits
              when 10..14 then label_range = 2
              when 15..17 then label_range = 2.5
              when 18..20 then label_range = 4
              when 21..35 then label_range = 5
              when 35..70 then label_range = 10
              when 71..99 then label_range = 20
            end
          when 8
            case top_2_digits
              when 10..16 then label_range = 2
              when 17..20 then label_range = 2.5
              when 21..25 then label_range = 4
              when 26..40 then label_range = 5
              when 41..80 then label_range = 10
              when 81..99 then label_range = 20
            end
          when 9
            case top_2_digits
              when 10..18 then label_range = 2
              when 19..22 then label_range = 2.5
              when 23..30 then label_range = 4
              when 31..45 then label_range = 5
              when 46..90 then label_range = 10
              when 91..99 then label_range = 20
            end
          else
            case top_2_digits
              when 10 then label_range = 1
              when 11..20 then label_range = 2
              when 21..25 then label_range = 2.5
              when 26..30 then label_range = 4
              when 31..50 then label_range = 5
              when 51..99 then label_range = 10
            end
        end
        label_range * (10 ** (figures_count(range) - 1))
      end

      def moderate_sub_axis(data, main_axis_settings, min=nil, max=nil)
        if min && max
          axis_ratio = (max - min).quo(main_axis_settings[:max] - main_axis_settings[:min])
          return {
            :max => max,
            :min => min,
            :min_scale_value => min + (main_axis_settings[:min_scale_value] - main_axis_settings[:min]) * axis_ratio,
            :axis_length => main_axis_settings[:axis_length],
            :scale_interval => main_axis_settings[:scale_interval] * axis_ratio
          }
        end
        scale_count = (main_axis_settings[:max] - main_axis_settings[:min_scale_value]).div(main_axis_settings[:scale_interval]) + (main_axis_settings[:min_scale_value] == main_axis_settings[:min] ? 0 : 1)
        data_min, data_max = chart_range(data, min, max)

        base_value = base_value(data_min, data_max, min.nil?, max.nil?)

        scale_interval = scale_interval(base_value, data_min, data_max, scale_count)
        scale_ratio = scale_interval.quo(main_axis_settings[:scale_interval])
        if min
          min_scale_value = scale_ratio * (main_axis_settings[:min_scale_value] - main_axis_settings[:min]) + min
          max = scale_ratio * (main_axis_settings[:max] - main_axis_settings[:min_scale_value]) + min_scale_value
        elsif max
          min_scale_value = max - scale_ratio * (main_axis_settings[:max] - main_axis_settings[:min_scale_value])
          min = min_scale_value - scale_ratio * (main_axis_settings[:min_scale_value] - main_axis_settings[:min])
        else
          min_scale_value = nil
          (base_value + scale_interval).step(data_min, -scale_interval) {|n| min_scale_value = n}
          min_scale_value ||= base_value + scale_interval
          min = min_scale_value - scale_ratio * (main_axis_settings[:min_scale_value] - main_axis_settings[:min])
          if data_min < min
            min_scale_value -= scale_interval
            min -= scale_interval
          end
          max = scale_ratio * (main_axis_settings[:max] - main_axis_settings[:min_scale_value]) + min_scale_value
        end

        {
          :min => min || min_scale_value - scale_interval,
          :max => max,
          :axis_length => main_axis_settings[:axis_length],
          :min_scale_value => min_scale_value,
          :scale_interval => scale_interval
        }
      end

      def chart_range(data, min=nil, max=nil)
        data = data.compact.flatten
        if min.nil? && max.nil?
          data_min, data_max = 
            data.inject([nil, nil]) do |(_min, _max), value|
              [value < (_min ||= value) ? value : _min,  (_max ||= value) < value ? value : _max]
            end
        elsif min && max && max < min
          data_min, data_max = max, min
        else
          data_min = min || [data.min, max].min
          data_max = max || [data.max, min].max
        end

        if data_min == data_max
          if data_min > 0
            data_min = 0
          elsif data_max < 0
            data_max = 0
          else
            data_min = 0
            data_max = 100
          end
        end
        [data_min, data_max]
      end

      def value_position_on_chart(chart_margin, axis_settings, value, reverse_direction = false)
        axis_settings[:axis_length] * 
          ((reverse_direction ? (axis_settings[:max] - value) : (value - axis_settings[:min])).to_f / (axis_settings[:max] - axis_settings[:min])) + 
          Length.new(chart_margin)
      end

      def order_position_on_chart(chart_margin, axis_length, count, index, type=:point, renge_width_ratio=0, reverse_direction=false)
        chart_margin = Length.new(chart_margin)
        pos =
            case type
              when :point then index.to_f / (count - 1)
              when :range then (index + 0.5 - renge_width_ratio.to_f / 2) / count
              else raise ArgumentError, "\"#{type}\" is invalid type"
            end
        axis_length * pos + chart_margin
      end

      def round_top_2_digit(max, min)
        digit = Math.log10([max.abs, min.abs].max).floor - 1
        [max.quo(10 ** digit).ceil * (10 ** digit), min.quo(10 ** digit).floor * (10 ** digit)]
      end

      def min_scale_value(max, min, scale_interval)
        return scale_interval if min == 0
        if (max_digit = Math.log10(max).to_i) != Math.log10(min).to_i
          base_value = 10 ** max_digit
        elsif max.div(10 ** max_digit) != min.div(10 ** max_digit)
          base_value = 9 * 10 ** max_digit
        else
          range_digit = Math.log10(max - min).floor
          base_value = max.div(10 ** range_digit) * (10 ** range_digit)
        end
        base_value - ((base_value - min).quo(scale_interval).ceil - 1) * scale_interval
      end
    end
  end
end

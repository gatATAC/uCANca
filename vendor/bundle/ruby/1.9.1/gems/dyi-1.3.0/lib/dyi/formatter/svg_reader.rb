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

require 'enumerator'
require 'rexml/document'

module DYI
  module Formatter

    # @since 0.0.0
    class SvgReader
      class << self
        def read(file_name)
          doc = REXML::Document.new(open(file_name))
          container = DYI::Shape::ShapeGroup.new
          doc.root.elements.each do |element|
            container.child_elements.push(create_shape(element))
          end
          container
        end

        private

        def create_shape(element)
          case element.name
            when 'g' then create_shape_group(element)
            when 'polygon' then create_polygon(element)
            when 'path' then create_path(element)
          end
        end

        def create_shape_group(element)
          group = DYI::Shape::ShapeGroup.new
          element.elements.each do |child|
            child_element = create_shape(child)
            group.child_elements.push(child_element) if child_element
          end
          group
        end

        def create_polygon(element)
          color = DYI::Color.new(element.attributes['fill']) if element.attributes['fill'] != 'none'
          points = element.attributes['points'].split(/\s+/).map {|pt| pt.scan(/-?[\.0-9]+/).map {|s| s.to_f}}
          path = nil
          points.each do |pt|
            if path
              path.line_to(pt)
            else
              path = DYI::Shape::Polygon.new(pt, :painting => {:fill => color})
            end
          end
          path
        end

        def create_path(element)
          color = DYI::Color.new(element.attributes['fill']) if element.attributes['fill'] != 'none'
          paths = element.attributes['d'].scan(/([MmZzLlHhVvCcSsQqTtAa])\s*([+-]?(?:\d+\.?\d*|\.\d+)(?:\s*,?\s*[+-]?(?:\d+\.?\d*|\.\d+))*)?/)
          enumerator = paths.each
          path_element = enumerator.next
          if path_element.first.upcase == 'M'
            lengths = path_element[1].scan(/[+-]?(?:\d+\.?\d*|\.\d+)/).map{|n| DYI::Length.new(n)}
            return if lengths.count % 2 == 1
            points = lengths.each_slice(2).map{|x, y| DYI::Coordinate.new(x, y)}
            path_data = DYI::Shape::Path::PathData.new(*points)
            loop do
              path_element = enumerator.next
              case path_element.first
              when 'M', 'm', 'L', 'l', 'C', 'c', 'S', 's', 'Q', 'q', 'T', 't'
                lengths = path_element[1].scan(/[+-]?(?:\d+\.?\d*|\.\d+)/).map{|n| DYI::Length.new(n)}
                return unless lengths.size % 2 == 0
                command_type = case path_element.first
                                 when 'M' then :move_to
                                 when 'm' then :rmove_to
                                 when 'L' then :line_to
                                 when 'l' then :rline_to
                                 when 'C' then :curve_to
                                 when 'c' then :rcurve_to
                                 when 'S' then :shorthand_curve_to
                                 when 's' then :rshorthand_curve_to
                                 when 'Q' then :quadratic_curve_to
                                 when 'q' then :rquadratic_curve_to
                                 when 'T' then :shorthand_quadratic_curve_to
                                 when 't' then :rshorthand_quadratic_curve_to
                               end
                points = lengths.each_slice(2).map{|x, y| DYI::Coordinate.new(x, y)}
                path_data.push_command(command_type, *points)
              when 'Z', 'z'
                path_data.push_command(:close_path, *lengths)
              when 'H', 'h', 'V', 'v'
                lengths = path_element[1].scan(/[+-]?(?:\d+\.?\d*|\.\d+)/).map{|n| DYI::Length.new(n)}
                command_type = case path_element.first
                                 when 'H' then :horizontal_lineto_to
                                 when 'h' then :rhorizontal_lineto_to
                                 when 'V' then :vertical_lineto_to
                                 when 'v' then :rvertical_lineto_to
                               end
                path_data.push_command(command_type, *lengths)
              when 'A', 'a'
                params = []
                enumerator = path_element[1].scan(/[+-]?(?:\d+\.?\d*|\.\d+)/).each
                return unless enumerator.count % 7 == 0
                loop do
                  rx = enumerator.next
                  ry = enumerator.next
                  rotation = enumerator.next
                  is_large_arc = enumerator.next
                  is_clockwise = enumerator.next
                  cx = enumerator.next
                  cy = enumerator.next
                  params << DYI::Length.new(rx) << DYI::Length.new(ry)
                  params << rotation.to_f
                  [is_large_arc, is_clockwise].each do |flg|
                    case flg
                      when '0' then params << false
                      when '1' then params << true
                      else return
                    end
                  end
                  params << Coordinate.new(cx, cy)
                end
                path_data.push_command(path_element.first == 'A' ? :arc_to : :rarc_to, *params)
              end
            end
          end
          DYI::Shape::Path.new(path_data, :painting => {:fill => color})
        end
      end
    end
  end
end

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

  # @since 0.0.0
  module SvgElement

    def draw_on(canvas)
      canvas.child_elements.push(self)
      self.root_node = canvas.root_node
      self
    end

    def save_as_svg(file_name)
      open(file_name, "w+b") {|io|
        puts_as_svg(io)
      }
    end

    def puts_as_svg(io=$>)
      io.puts(to_svg)
    end

    def puts_as_png(io=$>)
      io.puts(to_png)
    end

    def save(file_name, format=nil)
      if format
        format = format.to_s.downcase
      else
        file_name.scan(/.\.([^\.]+)$/) {|s| format = s[0].downcase}
      end

      format ||= 'svg'

      if format == 'svg'
        save_as_svg(file_name)
      elsif format == 'png'
        begin
          save_as_png(file_name)
        rescue
          tmp_file_name = file_name + '.temp'
          save_as_svg(tmp_file_name)
          system "\"#{INKSCAPE_PATH}\" -z -T -f #{File.expand_path(tmp_file_name)} -e #{File.expand_path(file_name)}"
          File.delete(tmp_file_name)
        end
      else
        tmp_file_name = file_name + '.temp'
        save_as_svg(tmp_file_name)
        opt =
          case format
            when 'ps' then opt = '-P'
            when 'eps' then opt = '-E'
            when 'pdf' then opt = '-A'
            else raise ArgumentError, "Unimplement Format: #{format}"
          end
        system "\"#{INKSCAPE_PATH}\" -z -T -f #{File.expand_path(tmp_file_name)} #{opt} #{File.expand_path(file_name)}"
        File.delete(tmp_file_name)
      end
    end

    def to_svg(xml=nil)
      unless xml
        xml = Builder::XmlMarkup.new :indent=>2
        xml.instruct!
        xml.declare! :DOCTYPE, :svg, :PUBLIC, "-//W3C//DTD SVG 1.0//EN", "http://www.w3.org/TR/2000/CR-SVG-20001102/DTD/svg-20001102.dtd"
        xml.svg(root_attributes.merge(:xmlns=>"http://www.w3.org/2000/svg")) {
          to_svg(xml)
        }
      else
        if respond_to?(:svg_tag, true)
          if draw_children?
            xml.tag!(svg_tag, svg_attributes) {
              child_elements_to_svg(xml)
            }
          else
            xml.tag!(svg_tag, svg_attributes)
          end
        else
          child_elements_to_svg(xml)
        end
      end
    end

    def to_png
      IO.popen('rsvg-convert', 'w+') {|pipe|
        puts_as_svg(pipe)
        pipe.close_write
        pipe.read
      }
    end

    private

    def draw_children?
      not child_elements.empty?
    end

    def svg_attributes
      attrs =
          attributes.inject({}) do |hash, (key, value)|
            hash[name_to_attribute(key).to_sym] = value if value
            hash
          end
      if respond_to?(:style) && style && !style.empty?
        sty =
            style.inject([]) do |array, (key, value)|
              array << "#{name_to_attribute(key)}:#{value}" if value
              array
            end
        attrs[:style] = sty.join(';')
      end
      attrs
    end

    def name_to_attribute(name)
      name.to_s.gsub(/_/,'-')
    end

    def root_attributes
      {}
    end

    def child_elements_to_svg(xml)
      child_elements.each {|child|
        child.to_svg(xml)
      }
    end
  end
end

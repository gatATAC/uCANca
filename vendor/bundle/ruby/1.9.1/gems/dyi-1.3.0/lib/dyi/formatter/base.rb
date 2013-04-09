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

require 'stringio'

module DYI
  module Formatter

    # @since 0.0.0
    class Base

      def initialize(canvas)
        @canvas = canvas
      end

      def puts(io=$>)
        raise NotImplementedError
      end

      def string
        puts(sio = StringIO.new)
        sio.string
      end

      def save(file_name, options={})
        open(file_name, "w") {|io| puts(io)}
      end

      def write_canvas(canvas, io)
        raise NotImplementedError
      end

      def write_rectangle(shape, io)
        raise NotImplementedError
      end

      def write_circle(shape, io)
        raise NotImplementedError
      end

      def write_ellipse(shape, io)
        raise NotImplementedError
      end

      def write_line(shape, io)
        raise NotImplementedError
      end

      def write_polyline(shape, io)
        raise NotImplementedError
      end

      def write_polygon(shape, io)
        raise NotImplementedError
      end

      def write_path(shape, io)
        raise NotImplementedError
      end

      # @since 1.0.0
      def write_image(shape, io)
      end

      def write_text(shape, io)
        raise NotImplementedError
      end

      def write_group(shape, io)
        raise NotImplementedError
      end
    end

    # @since 0.0.0
    module XmlChar
      # See http://intertwingly.net/stories/2004/04/14/i18n.html#CleaningWindows
      CP1252 = {     
        128 => 8364,  # euro sign
        130 => 8218,  # single low-9 quotation mark
        131 =>  402,  # latin small letter f with hook
        132 => 8222,  # double low-9 quotation mark
        133 => 8230,  # horizontal ellipsis
        134 => 8224,  # dagger
        135 => 8225,  # double dagger
        136 =>  710,  # modifier letter circumflex accent
        137 => 8240,  # per mille sign
        138 =>  352,  # latin capital letter s with caron
        139 => 8249,  # single left-pointing angle quotation mark
        140 =>  338,  # latin capital ligature oe
        142 =>  381,  # latin capital letter z with caron
        145 => 8216,  # left single quotation mark
        146 => 8217,  # right single quotation mark
        147 => 8220,  # left double quotation mark
        148 => 8221,  # right double quotation mark
        149 => 8226,  # bullet
        150 => 8211,  # en dash
        151 => 8212,  # em dash
        152 =>  732,  # small tilde
        153 => 8482,  # trade mark sign
        154 =>  353,  # latin small letter s with caron
        155 => 8250,  # single right-pointing angle quotation mark
        156 =>  339,  # latin small ligature oe
        158 =>  382,  # latin small letter z with caron
        159 =>  376   # latin capital letter y with diaeresis
      }

      # See http://www.w3.org/TR/REC-xml/#dt-chardata for details.
      PREDEFINED = {   
        38 => '&amp;',  # ampersand
        60 => '&lt;',   # left angle bracket
        62 => '&gt;'    # right angle bracket
      }

      # See http://www.w3.org/TR/REC-xml/#dt-chardata for details.
      ATTR_PREDEFINED = PREDEFINED.merge(
        34 => '&quot;',  # double quote
        39 => '&apos;'   # single quote
      )

      # See http://www.w3.org/TR/REC-xml/#charsets for details.
      VALID = [
        0x9, 0xA, 0xD,
        (0x20..0xD7FF),
        (0xE000..0xFFFD),
        (0x10000..0x10FFFF)
      ]

      private

      def escape(s)
        s.to_s.unpack('U*').map {|n| code_to_char(n)}.join # ASCII, UTF-8
      rescue
        s.to_s.unpack('C*').map {|n| code_to_char(n)}.join # ISO-8859-1, WIN-1252
      end

      def attr_escape(s)
        s.to_s.unpack('U*').map {|n| code_to_char(n, true)}.join # ASCII, UTF-8
      rescue
        s.to_s.unpack('C*').map {|n| code_to_char(n, true)}.join # ISO-8859-1, WIN-1252
      end

      def code_to_char(code, is_attr=false)
        code = CP1252[code] || code
        case code when *VALID
          (is_attr ? ATTR_PREDEFINED : PREDEFINED)[code] || (code<128 ? code.chr : "&##{code};")
        else
          '*'
        end
      end
    end

    # @since 0.0.0
    class XmlFormatter < Base
      include XmlChar

      # @since 1.1.0
      attr_reader :namespace

      def initialize(canvas, options={})
        @canvas = canvas
        @indent = options[:indent] || 0
        @level = options[:level] || 0
        @inline_mode = options[:inline_mode]
        namespace = options[:namespace].to_s
        @namespace = namespace.empty? ? nil : namespace
      end

      # @since 1.1.0
      def inline_mode?
        @inline_mode ? true : false
      end

      # @since 1.1.0
      def inline_mode=(boolean)
        @inline_mode = boolean ? true : false
      end

      # @since 1.0.0
      def xml_instruction
        %Q{<?xml version="1.0" encoding="UTF-8"?>}
      end

      # @since 1.0.0
      def stylesheet_instruction(stylesheet)
        styles = []
        styles << '<?xml-stylesheet href="'
        styles << stylesheet.href
        styles << '" type="'
        styles << stylesheet.content_type
        if stylesheet.title
          styles << '" title="'
          styles << stylesheet.title
        end
        if stylesheet.media
          styles << '" media="'
          styles << stylesheet.media
        end
        styles << '"?>'
        styles.join
      end

      def generator_comment
        %Q{<!-- Create with DYI #{DYI::VERSION} (#{DYI::URL}) -->}
      end

      def declaration
        ''
      end

      def puts(io=$>)
        if @canvas.root_element? && !inline_mode?
          puts_line(io) {io << xml_instruction}
          @canvas.stylesheets.each do |stylesheet|
            if stylesheet.include_external_file?
              puts_line(io) {io << stylesheet_instruction(stylesheet)}
            end
          end
          puts_line(io) {io << generator_comment}
          declaration.each_line do |dec|
            puts_line(io) {io << dec}
          end
        end
        @canvas.write_as(self, io)
      end

      private

      def puts_line(io, &block)
        io << (' ' * (@indent * @level)) if @indent != 0 && @level != 0
        yield io
        io << "\n" if @indent != 0
      end

      def create_node(io, tag_name, attributes={}, &block)
        _tag_name = @namespace ? "#{namespace}:#{tag_name}" : tag_name
        puts_line(io) {
          io << '<' << _tag_name
          attributes.each do |key, value|
            io << ' ' << key << '="' << attr_escape(value) << '"'
          end
          io << '>'
        }
        create_nested_nodes(io, &block) if block
        puts_line(io) {io << '</' << _tag_name << '>'}
      end

      def create_leaf_node(io, tag_name, *attr)
        _tag_name = @namespace ? "#{namespace}:#{tag_name}" : tag_name
        puts_line(io) {
          io << '<' << _tag_name
          if attr.first.kind_of?(Hash)
            attr.first.each do |key, value|
              io << ' ' << key << '="' << attr_escape(value) << '"'
            end
            io << '/>'
          elsif attr[1].kind_of?(Hash)
            attr[1].each do |key, value|
              io << ' ' << key << '="' << attr_escape(value) << '"'
            end
            io << '>' << escape(attr.first) << '</' << _tag_name << '>'
          elsif attr.first.nil?
            io << '/>'
          else
            io << '>' << escape(attr.first) << '</' << _tag_name << '>'
          end
        }
      end

      def create_nested_nodes(io, &block)
        @level += 1
        yield io
      ensure
        @level -= 1
      end

      # @since 1.0.0
      def create_cdata_node(io, tag_name, attributes={}, &block)
        _tag_name = @namespace ? "#{namespace}:#{tag_name}" : tag_name
        puts_line(io) {
          io << '<' << _tag_name
          attributes.each do |key, value|
            io << ' ' << key << '="' << attr_escape(value) << '"'
          end
          io << '><![CDATA['
        }
        yield
        puts_line(io) {io << ']]></' << _tag_name << '>'}
      end
    end
  end
end

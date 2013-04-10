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
# == Overview
#
# This file provides the classes of client side scripting.  The event becomes
# effective only when it is output by SVG format.

#
module DYI

  # @since 1.0.0
  module Stylesheet

    class Style

      # @return [String] content-type of script
      attr_reader :content_type
      # @return [String] body of client scripting
      attr_reader :body
      attr_reader :media, :title

      # @param [String] body body of client scripting
      # @param [String] content_type content-type of script
      def initialize(body, content_type='text/css', options={})
        @content_type = content_type
        @body = body
        @media = options[:media]
        @title = options[:title]
      end

      def include_external_file?
        false
      end

      # Returns this script includes reference of external script file.
      # @return [Boolean] always returns false
      def has_uri_reference?
        false
      end

      # Writes the buffer contents of the object.
      # @param [Formatter::Base] a formatter for export
      # @param [IO] io a buffer that is written
      def write_as(formatter, io=$>)
        formatter.write_style(self, io)
      end
    end

    class StyleReference < Style

      # @return [String] a path of external style-sheet file
      attr_reader :href

      def initialize(href, content_type='text/css', options={})
        super(nil, content_type, options)
        @href = href
      end

      # Returns whether this script contains reference of external style-sheet
      # file.
      # @return [Boolean] always returns true
      def include_external_file?
        true
      end
    end
  end
end
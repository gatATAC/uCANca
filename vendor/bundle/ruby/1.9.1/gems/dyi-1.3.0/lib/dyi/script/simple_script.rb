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

  # @since 1.0.0
  module Script

    # Class representing a inline-client-script.  The scripting becomes
    # effective only when it is output by SVG format.
    class SimpleScript

      # @return [String] content-type of script
      attr_reader :content_type
      # @return [String] body of client scripting
      attr_reader :body

      # @param [String] body body of client scripting
      # @param [String] content_type content-type of script
      def initialize(body, content_type = 'application/ecmascript')
        @content_type = content_type
        @body = body
      end

      # Returns this script includes reference of external script file.
      # @return [Boolean] always returns false
      def include_external_file?
        false
      end

      # Returns this script includes reference of external script file.
      # @return [Boolean] always returns false
      def has_uri_reference?
        false
      end

      # Appends script.
      # @param [String] script_body body of client scripting that is appended
      # @since 1.0.2
      def append_body(script_body)
        if @body.to_s[-1,1] == "\n"
          @body += script_body
        else
          @body = [@body, "\n", script_body].join
        end
      end

      # @since 1.0.3
      def contents
        @body
      end

      # Writes the buffer contents of the object.
      # @param [Formatter::Base] a formatter for export
      # @param [IO] io a buffer that is written
      def write_as(formatter, io=$>)
        formatter.write_script(self, io)
      end
    end

    # Class representing a referenct of external client-script-file.
    # The scripting becomes effective only when it is output by SVG format.
    class ScriptReference < SimpleScript

      # @return [String] a path of external script file
      attr_reader :href

      def initialize(href, content_type = 'application/ecmascript')
        super(nil, content_type)
        @href = href
      end

      # Returns whether this script contains reference of external script file.
      # @return [Boolean] always returns true
      def include_external_file?
        true
      end

      # Returns whether this script contains reference of external script file.
      # @return [Boolean] always returns true
      def has_uri_reference?
        true
      end
    end
  end
end
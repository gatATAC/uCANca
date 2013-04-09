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

begin
  require 'win32ole' # for Windows
rescue LoadError
  # do notiong
end

require 'date'
require 'nkf'

module DYI
  module Chart

    # +ExcelReader+ class provides a interface to Microsoft Excel file and data
    # for a chart object. Creating the instance, you should not call +new+
    # method but {.read} method.
    #
    # This class requires that _win32ole_ has been installed your system.
    # @see ArrayReader
    # @since 0.0.0
    class ExcelReader < ArrayReader

      # @private
      OFFSET = DateTime.now.offset

      # Parses Excel file and sets data.
      # @param [String] path a path of the Excel file
      # @option (see ArrayReader#read)
      # @option options [String, Integer] :sheet sheet name of data source or
      #   sheet number (starting from 1)
      # @raise [NotImplementedError] _win32ole_ has not been installed
      # @see ArrayReader#read
      def read(path, options={})
        if defined? WIN32OLE
          # for Windows
          path = WIN32OLE.new('Scripting.FileSystemObject').getAbsolutePathName(path)
          excel = WIN32OLE.new('Excel.Application')
          book = excel.workbooks.open(path)
          sheet = book.worksheets.item(options[:sheet] || 1)
          range = sheet.usedRange
          sheet_values = sheet.range(sheet.cells(1,1), sheet.cells(range.end(4).row, range.end(2).column)).value
        else
          # except Windows
          raise NotImplementedError, 'win32ole has not been installed'
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

      private

      def primitive_value(value, type=nil)
        if defined? WIN32OLE
          # for Windows
          case value
          when String
            if value =~ %r(^(\d{4})/(\d{2})/(\d{2}) (\d{2}):(\d{2}):(\d{2})$)
              DateTime.new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i, OFFSET)
            elsif value.size == 0
              nil
            else
              NKF.nkf('-w -S -m0 -x --cp932', value)
            end
          when Numeric, nil, true, false
            value
          when System::DateTime
            # for IronRuby
            DateTime.new(value.Year, value.Month, value.Day, value.Hour, value.Minute, value.Second, OFFSET)
          else
            value
          end rescue value
        else
          # except Windows
          raise NotImplementedError, 'win32ole is not installed'
        end
      end

      class << self

        # Parses Excel file and creates instance of ExcelReader.
        # @param (see #read)
        # @option (see #read)
        # @return [ExcelReader] a new instance of ExcelReader
        # @raise (see #read)
        # @see ArrayReader.read
        def read(path, options={})
          new.read(path, options)
        end
      end
    end
  end
end

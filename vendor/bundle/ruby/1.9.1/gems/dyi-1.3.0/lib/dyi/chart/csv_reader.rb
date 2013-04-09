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
require 'date'
require 'bigdecimal'
require 'nkf'

module DYI
  module Chart

    # +CsvReader+ class provides a interface to CSV file and data for a chart
    # object.
    #
    #= Basic Usage
    #
    # Using +PieChart+ and CsvReader, you can create the pie chart as the
    # following:
    #   # contents of asian_gdp.csv
    #   # -------------------------
    #   # China,5878
    #   # Japan,5459
    #   # India,1538
    #   # South Koria,1007
    #   # Other Countries, 2863
    #   
    #   require 'rubygems'
    #   require 'dyi'
    #   
    #   reader = DYI::Chart::CsvReader.read('asian_gdp.csv',
    #                                       :schema => [:name, :value],
    #                                       :data_types => [:string, :number])
    #   
    #   # Creates the Pie Chart
    #   chart = DYI::Chart::PieChart.new(450,250)
    #   chart.load_data(reader)
    #   chart.save('asian_gdp.svg')
    # Creating the instance, you should not call +new+ method but {.read} method.
    #
    # The optional argument +:schema+ means a field name. See {ArrayReader} for
    # +:schema+ option. The optional argument +:data_types+ means data types of
    # the field. Using this option, +CsvReader+ converts text data that the CSV
    # data included into a appropriate ruby object. (+:data_types+ option has
    # been implemented in +ArrayReader+, although +ArrayReader+ ignores this
    # option.) If +:data_types+ option is not specified, the values of all the
    # fields are converted into instances of +Float+. +:data_types+ option can
    # specify the following values: +:string+, +:decimal+, +:number+(synonym of
    # +:decimal+), +:float+, +:integer+, +:date+, +:datetime+, +:boolean+
    #
    # See {CsvReader.read CsvReader.read} for other optional arguments.
    # @see ArrayReader
    # @see ArrayReader.read
    # @since 0.0.0
    class CsvReader < ArrayReader

      # @private
      alias __org_read__ read

      # Parses CSV data and sets data.
      # @param [String] csv CSV data
      # @option (see ArrayReader#read)
      # @option options [Array<Symbol>] :data_types array of field data types
      # @option options [String] :date_format date format string of CSV data,
      #   parsing a date string in CSV at +Date#strptime+
      # @option options [String] :datetime_format date-time format string of CSV
      #   data, parsing a date-time string in CSV at +DateTime#strptime+
      # @option options [Symbol] :encode encoding of CSV data as the following:
      #   +:utf8+ (default), +:sjis+, +:euc+, +:jis+ (ISO-2022-JP), +:utf16+
      #   (UTF-16BE)
      # @option options [String] :col_sep a separator of columns, default to
      #   <tt>","</tt>
      # @option options [String] :row_sep a separator of rows, default to
      #   +:auto+, which means that a separetor is <tt>"\r\n"</tt>,
      #   <tt>"\n"</tt>, or <tt>"\r"</tt> sequence
      # @raise [ArgumentError] unknown encode is given for +:encode+
      # @see ArrayReader#read
      # @since 1.1.1
      def parse(csv, options={})
        options = options.clone
        @date_format = options.delete(:date_format)
        @datetime_format = options.delete(:datetime_format)
        nkf_options =
          case (options[:encode] || :utf8).to_sym
            when :utf8 then nil
            when :sjis then '-w -S -m0 -x --cp932'
            when :euc then '-w -E -m0 -x --cp932'
            when :jis then '-w -J -m0 -x'
            when :utf16 then '-w -W16 -m0 -x'
            else raise ArgumentError,"Unknown encode: `#{@encode}'"
          end
        parsed_array = 
          if RUBY_VERSION >= '1.9'
            CSV.parse(nkf_options ? NKF.nkf(nkf_options, csv) : csv, :col_sep => options[:col_sep] || ',', :row_sep => options[:row_sep] || :auto)
          else
            CSV.parse(nkf_options ? NKF.nkf(nkf_options, csv) : csv, options[:col_sep], options[:row_sep])
          end
        __org_read__(parsed_array, options)
      end

      # Parses CSV file and sets data.
      # @param [String] path a path of the CSV file
      # @option (see #parse)
      # @raise (see #parse)
      # @see (see #parse)
      def read(path, options={})
        parse(IO.read(path), options)
      end

      private

      def primitive_value(value, type)
        if type.is_a?(Symbol) || type.is_a?(String)
          case type.to_sym
          when :string
            value
          when :number, :decimal
            value ? BigDecimal.new(value) : nil
          when :float
            value ? value.to_f : nil
          when :integer
            value ? value.to_i : nil
          when :date
            return nil if value.nil?
            @date_format ? Date.strptime(value, @date_format) : Date.parse(value)
          when :datetime
            return nil if value.nil?
            @datetime_format ? DateTime.strptime(value, @datetime_format) : DateTime.parse(value)
          when :boolean
            value ? true : value
          else
            value ? value.to_f : nil
          end
        else
          value ? value.to_f : nil
        end
      end

      class << self
        # Parses CSV file and creates instance of CsvReader.
        # @param (see #read)
        # @option (see #read)
        # @return (see .parse)
        # @raise (see #read)
        # @see (see .parse)
        def read(path, options={})
          new.read(path, options)
        end

        # Parses CSV data and creates instance of CsvReader.
        # @param (see #parse)
        # @option (see #parse)
        # @return [CsvReader] a new instance of CsvReader
        # @raise (see #parse)
        # @see ArrayReader.read
        # @since 1.1.1
        def parse(csv, options={})
          new.parse(csv, options)
        end
      end
    end
  end
end

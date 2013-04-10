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

    # +ArrayReader+ converts the ruby array into a readable format for the
    # chart object of DYI.
    #
    # If any ruby object or something (file, database, etc...) is used as the
    # data source of DYI's chart, the object of the inheritance class of
    # +ArrayReader+ avails. For example, using a CSV data, {CsvReader} class
    # avails.
    #
    #= Basic Usage
    #
    # Using +PieChart+ and ArrayReader (or sub class of ArrayReader), you can
    # create the pie chart as the following:
    #   require 'rubygems'
    #   require 'dyi'
    #   
    #   # Nominal GDP of Asian Countries (2010)
    #   chart_data = [['China', 5878],
    #                 ['Japan', 5459],
    #                 ['India', 1538],
    #                 ['South Koria', 1007],
    #                 ['Other Countries', 2863]]
    #   reader = DYI::Chart::ArrayReader.read(chart_data, :schema => [:name, :value])
    #
    #   # Creates the Pie Chart
    #   chart = DYI::Chart::PieChart.new(450,250)
    #   chart.load_data(reader)
    #   chart.save('asian_gdp.svg')
    # Creating the instance, you should not call +new+ method but {.read} method.
    #
    # The optional argument +:schema+ means a field name. The field name +:value+
    # is the particular name, that is to say, the chart object generate a chart
    # using a value of the field named +:value+. If +:schema+ option is not
    # specified, the +ArrayReader+ object looks upon all feilds as +:vlaue+
    # field. The field names other than +:name+ are used in the format string
    # and so on, as following:
    #   # Nominal GDP of Asian Countries (2010)
    #   chart_data = [['China',       'People\'s Republic of China', 5878, 'red'],
    #                 ['Japan',       'Japan',                       5459, 'blue'],
    #                 ['India',       'Republic of India',           1538, 'yellow'],
    #                 ['South Koria', 'Republic of Korea',           1007, 'green'],
    #                 ['Others',      'Other Asian Countries',       2863, 'gray']]
    #   reader = DYI::Chart::ArrayReader.read(chart_data,
    #                                         :schema => [:name, :long, :value, :color])
    #
    #   # Creates the Pie Chart
    #   chart = DYI::Chart::PieChart.new(450,250,
    #                                    :legend_format => '{?long}')
    #   chart.load_data(reader)
    #   chart.save('asian_gdp.svg')
    # See {ArrayReader.read ArrayReader.read} for other optional arguments.
    # @since 0.0.0
    class ArrayReader
      include Enumerable

      # Returns the value at index.
      # @param [Integer] i the index of records
      # @param [Integer] j the index of series
      # @return [Numeric] the value at index
      def [](i, j)
        @records[i].values[j]
      end

      # Returns the array of the records.
      # @return [Array<Struct>] the array of the records
      # @since 1.0.0
      def records
        @records.clone
      end

      # Returns number of the records.
      # @return [Integer] number of the records
      # @since 1.0.0
      def records_size
        @records.size
      end

      # Returns number of the values in the record
      # @return [Integer] number of the values
      # @since 1.0.0
      def values_size
        @records.first.values.size rescue 0
      end

      # Clears all records
      def clear_data
        @records.clear
      end

      # Calls block once for each record, passing the values that records as a
      # parameter.
      # @yield [values] iteration block
      # @yieldparam [Array<Numeric>] values the values that the record has
      # @since 1.0.0
      def values_each(&block)
        @records.each do |record|
          yield record.values
        end
      end

      # Returns an array of values of the specified series.
      # @param [Integer] index an index of the series
      # @return [Array<Numeric>] an array of values
      # @since 1.0.0
      def series(index)
        @records.map do |record|
          record.values[index]
        end
      end

      # Returns whether the record has the field.
      # @param [Symbol, String] field_name field name
      # @return [Bolean] true if the record has the field, false otherwise
      # @since 1.0.0
      def has_field?(field_name)
        @schema.members.include?(RUBY_VERSION >= '1.9' ? field_name.to_sym : field_name.to_s)
      end

      # Calls block once for each record, passing that records as a parameter.
      # @yield [record] iteration block
      # @yieldparam [Struct] record the record in self
      # @since 1.0.0
      def each(&block)
        @records.each(&block)
      end

      # @private
      def initialize
        @records = []
      end

      # Loads array-of-array and sets data.
      # @param [Array<Array>] array_of_array two dimensional array
      # @option options [Range] :row_range a range of rows
      # @option options [Range] :column_range a range of columns
      # @option options [Array<Symbol>] :schema array of field names. see
      #   Overview of {ArrayReader}.
      # @option options [Boolean] :transposed whether the array-of-array is
      #   transposed
      def read(array_of_array, options={})
        clear_data
        row_range = options[:row_range] || (0..-1)
        col_range = options[:column_range] || (0..-1)
        schema = options[:schema] || [:value]
        data_types = options[:data_types] || []
#        row_proc = options[:row_proc]
        @schema = record_schema(schema)
        array_of_array = transpose(array_of_array) if options[:transposed]

        array_of_array[row_range].each do |row|
          record_source = []
          values = []
          has_set_value = false
          row[col_range].each_with_index do |cell, i|
            cell = primitive_value(cell, data_types[i])
            if schema[i].nil? || schema[i].to_sym == :value
              unless has_set_value
                record_source << cell
                has_set_value = true
              end
              values << cell
            else
              record_source << cell
            end
          end
          record_source << values
          @records << @schema.new(*record_source)
        end
        self
      end

      # Returns an array of the field's name
      # @return [Array<Symbol>] an array of the field's name
      # @since 1.1.0
      def members
        @schema.members.map{|name| name.to_sym}
      end

      private

      def primitive_value(value, type=nil)
        value
      end

      # Transposes row and column of array-of-array.
      # @example
      #   transpose([[0,1,2],[3,4,5]]) => [[0,3],[1,4],[2,5]]
      # @param [Array] array_of_array array of array
      # @return [Array] transposed array
      # @since 1.0.0
      def transpose(array_of_array)
        transposed_array = []
        array_of_array.each_with_index do |row, i|
          row.each_with_index do |cell, j|
            transposed_array[j] ||= Array.new(i)
            transposed_array[j] << cell
          end
        end
        transposed_array
      end

      # @param [Array] schema of the record
      # @return [Class] subclass of Struct class
      # @raise [ArgumentError]
      # @since 1.0.0
      def record_schema(schema)
        struct_schema =
            schema.inject([]) do |result, name|
              if result.include?(name.to_sym)
                if name.to_sym == :value
                  next result
                else
                  raise ArgumentError, "schema option has a duplicate name: `#{name}'"
                end
              end
              if name.to_sym == :values
                raise ArgumentError, "schema option may not contain `:values'"
              end
              result << name.to_sym
            end
        struct_schema << :values
        Struct.new(*struct_schema)
      end

      # Makes the instance respond to +xxx_values+ method.
      # @example
      #   data = ArrayReader.read([['Smith', 20, 3432], ['Thomas', 25, 9721]],
      #                           :schema => [:name, :age, :value])
      #   data.name_vlaues  # => ['Smith', 'Thomas']
      #   data.age_values   # => [20, 25]
      # @since 1.0.0
      def method_missing(name, *args)
        if args.size == 0 && name.to_s =~ /_values\z/ &&
            @schema.members.include?(RUBY_VERSION >= '1.9' ? $`.to_sym : $`)
          @records.map{|r| r.__send__($`)}
        else
          super
        end
      end

      class << self
        # Create a new instance of ArrayReader, loading array-of-array.
        # @param (see #read)
        # @option (see #read)
        # @return [ArrayReader] a new instance of ArrayReader
        # @example
        #   # example of using :row_range option
        #   chart_data = [['Country', 'Nominal GDP'],
        #                 ['China', 5878],
        #                 ['Japan', 5459],
        #                 ['India', 1538],
        #                 ['South Koria', 1007],
        #                 ['Other Countries', 2863]]
        #   # skips the first row
        #   reader = DYI::Chart::ArrayReader.read(chart_data,
        #                                         :schema => [:name, :value],
        #                                         :row_range => (1..-1))
        # @example
        #   # example of using :transposed option
        #   chart_data = [['China', 'Japan', 'India', 'South Koria', 'Other Countries'],
        #                 [5878, 5459, 1538, 1007, 2863]]
        #   # transposes the rows and the columns
        #   reader = DYI::Chart::ArrayReader.read(chart_data,
        #                                           :schema => [:name, :value],
        #                                           :transposed => true)
        def read(array_of_array, options={})
          new.read(array_of_array, options)
        end
      end
    end
  end
end

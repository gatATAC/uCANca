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
  class Font
    IMPLEMENT_ATTRIBUTES = [:font_family, :style, :variant, :weight, :size, :size_adjust, :stretch]
    VALID_VALUES = {
      :style => ['normal','italic','oblique'],
      :variant => ['normal','small-caps'],
      :weight => ['normal','bold','bolder','lighter','100','200','300','400','500','600','700','800','900'],
      :stretch => ['normal','wider','narrower','ultra-condensed','extra-condensed','condensed','semi-condensed','semi-expanded','expanded','extra-expanded','ultra-expanded']
    }
    DEFAULT_SIZE = Length.new(16)

    ##
    # :method: font_family

    ##
    # :method: style

    ##
    # :method: weight

    ##
    # :method: size

    ##
    attr_reader *IMPLEMENT_ATTRIBUTES

    def initialize(options={})
      case options
      when Font
        IMPLEMENT_ATTRIBUTES.each do |attr|
          instance_variable_set("@#{attr}", options.__send__(attr))
        end
      when Hash
        options.each do |attr, value|
          __send__(attr.to_s + '=', value) if IMPLEMENT_ATTRIBUTES.include?(attr.to_sym)
        end
      else
        raise TypeError, "#{options.class} can't be coerced into #{self.class}"
      end
    end

    ##
    # :method: style=
    # 
    # :call-seq:
    # style= (value)
    # 

    ##
    # :method: weight=
    # 
    # :call-seq:
    # weight= (value)
    # 

    ##
    VALID_VALUES.each do |attr, valid_values|
      define_method("#{attr.to_s}=") {|value|
        if (value = value.to_s).size == 0
          instance_variable_set("@#{attr}", nil)
        else
          raise ArgumentError, "`#{value}' is invalid font-#{attr}" unless VALID_VALUES[attr].include?(value)
          instance_variable_set("@#{attr}", value)
        end
      }
    end

    def font_family=(value)
      @font_family = value.to_s.size != 0 ? value.to_s : nil
    end

    def size=(value)
      @size = Length.new_or_nil(value)
    end

    def size_adjust=(value)
      @size_adjust = value ? value.to_f : nil
    end

    def draw_size
      @size || DEFAULT_SIZE
    end

    def attributes
      IMPLEMENT_ATTRIBUTES.inject({}) do |hash, attr|
        value = instance_variable_get("@#{attr}")
        hash[/^font_/ =~ attr.to_s ? attr : "font_#{attr}".to_sym] = value.to_s unless value.nil?
        hash
      end
    end

    def empty?
      IMPLEMENT_ATTRIBUTES.all? do |attr|
        not instance_variable_get("@#{attr}")
      end
    end

    class << self

      def new(*args)
        return args.first if args.size == 1 && args.first.instance_of?(self)
        super
      end

      def new_or_nil(*args)
        (args.size == 1 && args.first.nil?) ? nil : new(*args)
      end
    end
  end
end

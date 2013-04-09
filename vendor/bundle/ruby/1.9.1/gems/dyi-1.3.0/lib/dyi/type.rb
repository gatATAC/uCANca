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
  module AttributeCreator

    private

    def attr_font(*names)
      names.each do |name|
        define_method(name.to_sym) {| |
          instance_variable_get("@#{name}") || Font.new
        }
        define_method("#{name}=".to_sym) {|font|
          instance_variable_set("@#{name}", Font.new_or_nil(font))
        }
      end
    end

    def attr_painting(*names)
      names.each do |name|
        define_method(name.to_sym) {| |
          instance_variable_get("@#{name}") || Painting.new
        }
        define_method("#{name}=".to_sym) {|painting|
          instance_variable_set("@#{name}", Painting.new_or_nil(painting))
        }
      end
    end

    def attr_length(*names)
      names.each do |name|
        define_method(name.to_sym) {| |
          instance_variable_get("@#{name}")
        }
        define_method("#{name}=".to_sym) {|length|
          instance_variable_set("@#{name}", Length.new(length))
        }
      end
    end

    def attr_coordinate(*names)
      names.each do |name|
        define_method(name.to_sym) {| |
          instance_variable_get("@#{name}")
        }
        define_method("#{name}=".to_sym) {|coordinate|
          instance_variable_set("@#{name}", Coordinate.new(coordinate))
        }
      end
    end
  end

  # @since 0.0.0
  module StringFormat

    class << self

      # :call-seq:
      # set_default_formats (formats)
      # set_default_formats (formats) { ... }
      # 
      def set_default_formats(formats)
        org_formats = {}
        if formats.key?(:color)
          org_formats[:color] = Color.default_format
          Color.set_default_format(*formats[:color])
        end
        if formats.key?(:length)
          org_formats[:length] = Length.default_format
          Length.set_default_format(*formats[:length])
        end
        if formats.key?(:coordinate)
          org_formats[:coordinate] = Coordinate.default_format
          Coordinate.set_default_format(*formats[:coordinate])
        end
        if block_given?
          yield
          Color.set_default_format(*org_formats[:color]) if org_formats.key?(:color)
          Length.set_default_format(*org_formats[:length]) if org_formats.key?(:length)
          Coordinate.set_default_format(*org_formats[:coordinate]) if org_formats.key?(:coordinate)
        end
      end
    end
  end
end

# -*- encoding: UTF-8 -*-

# Copyright (c) 2009-2012 Sound-F Co., Ltd. All rights reserved.
#
# Author:: Mamoru Yuo
#
# This file is part of "DYI for Rails".
#
# "DYI for Rails" is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# "DYI for Rails" is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with "DYI for Rails".  If not, see <http://www.gnu.org/licenses/>.

# Root namespace of "DYI for Rails".
# @since 0.0.0
module DyiRails

  # "DYI for Rails" program version
  VERSION = '0.0.0'

  # URL of "DYI for Rails" Project
  URL = 'http://sourceforge.net/projects/dyi-rails/'

  # The correspondence of the image format to the mime-type
  MIME_TYPE = {:svg => 'image/svg+xml',
               :png => 'image/png',
               :eps => 'application/postscript',
               :xaml => 'application/xaml+xml'}

  class << self

    # Registers new correspondence of the image format to mime-type. When the
    # image format has already registered, mime-type is overriden.
    # @param [Symbol, String] format image format
    # @param [String] mime_type mime-type which the image format corresponds to
    def register_mime_type(format, mime_type)
      MIME_TYPE[format.to_sym] = mime_type.to_s
    end

    # Returns mime-type which the given image format corresponds to.
    # @param [Symbol, String] format image format
    # @return [String] mime-type which the image format corresponds to
    # @raise [ArgumentError] unknown format is given
    def mime_type(format)
      format = format.to_sym
      unless MIME_TYPE.has_key?(format)
        raise ArgumentError, "`#{options[:format]}' is unknown format"
      end
      return MIME_TYPE[format]
    end
  end
end

require 'dyi'

%w(

dyi_rails/dyi_helper.rb
dyi_rails/streaming.rb

).each do |file_name|
  require File.join(File.dirname(__FILE__), file_name)
end

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


module DyiRails

  # Provides a set of methods for sending the image using DYI on the Rails'
  # controller.
  module Streaming

    # Sends image the image using DYI on the Rails' controller.
    # @param [DYI::Canvas, DYI::Chart::Base] canvas a canvas that hold the image
    # @option options [Symbol, String] :format format of the image. Default to
    #   +:svg+
    # @option options [String] :namespace XML namespace when XML format (e.g.
    #   SVG) is specified at +:format+ option. If nothing is specified,
    #   XML namespace is not used
    # @option options [String] :file_name suggests a filename for the browser to
    #   use
    # @option options [String] :disposition specifies whether the file will be
    #   shown inline or downloaded. Valid values are <tt>'inline'</tt> and
    #   <tt>'attachment'</tt> (default)
    # @option options [String] :status specifies the status code to send with
    #   the response. Defaults to <tt>'200 OK'</tt>
    # @example
    #   class TeamsController < ApplicationController
    #     include DyiRails::Streaming
    #   
    #     # responses /teams/emblem/any_id.svg
    #     def emblem
    #       # creates image using DYI
    #       canvas = DYI::Canvas.new(200, 150)
    #       # codes to draw an image
    #   
    #       # sends image data
    #       send_dyi_image(canvas, :format => params['format'])
    #     end
    #   end
    def send_dyi_image(canvas, options={})
      opt = options.clone
      format = opt.delete(:format) || :svg
      namespace = opt.delete(:namespace)
      opt[:type] = DyiRails.mime_type(format)
      send_data(canvas.string(format, :namespace => namespace), opt)
    end
  end
end

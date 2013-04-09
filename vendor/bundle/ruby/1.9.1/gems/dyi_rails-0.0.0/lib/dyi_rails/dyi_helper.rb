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

  # Provides a set of methods for making image tags using DYI.
  module DyiHelper

    # Returns a inline HTML element. The HTML element does not have a URI
    # reference, and the element contains the image data itself.
    # @param [DYI::Canvas, DYI::Chart::Base] canvas a canvas that hold the image
    # @option options [String] :id id of the HTML element. If the canvas has
    #   _id_ attribute, this option is ignored.
    # @option options [String] :class CSS class name of the HTML element
    # @option options [String] :alt equivalent content for those who cannot
    #   process images or who have image loading disabled. If the canvas has
    #   _description_ attribute, this option is ignored. Default to <tt>'dyi
    #   image'</tt>
    # @option options [String] :title title of the image. If the canvas has
    #   _title_ attribute, this option is ignored
    # @option options [Symbol, String] :format format of the image. Default to
    #   +:svg+
    # @option options [String] :namespace XML namespace when XML format (e.g.
    #   SVG) is specified at +:format+ option. If nothing is specified,
    #   XML namespace is not used
    # @return [String] HTML element contains image data
    # @example
    #   dyi_inline_image_tag(@canvas, :alt => 'my image')
    #   # => <svg width="200" height="150" version="1.1" viewBox="0 0 200 150"
    #   #         xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
    #   #      <description>my image</description>
    #   #      ...
    #   #    </svg>
    #   
    #   dyi_inline_image_tag(@canvas, :alt => 'my image', :namespace => 'svg')
    #   # => <svg:svg width="200" height="150" version="1.1" viewBox="0 0 200 150"
    #   #         xmlns:svg="http://www.w3.org/2000/svg" preserveAspectRatio="none">
    #   #      <svg:description>my image</svg:description>
    #   #      ...
    #   #    </svg:svg>
    #   
    #   dyi_inline_image_tag(@canvas, :alt => 'my image', :format => :png)
    #   # => <img width="200" height="150" alt="my image" src="data:image/png;base64,
    #   #         ...(encoded PNG image)..." />
    def dyi_inline_image_tag(canvas, options={})
      case (format = (options[:format] || :svg).to_sym)
      when :svg, :xaml #, :vml
        # output inline XML
        alt = canvas.description || options[:alt] || 'dyi image'

        canvas.id = options[:id] if options[:id] && !canvas.inner_id
        canvas.add_css_class(options[:class]) if options[:class]
        canvas.description = alt unless canvas.description
        canvas.title = options[:title] if options[:title] && !canvas.title
        canvas.string(format, :inline_mode => true, :namespace => options[:namespace])
      when :png
        # output <img> tag with base64 encoding
        element_id = canvas.inner_id || options[:id]
        class_name = options[:class]
        alt = canvas.description || options[:alt] || 'dyi image'
        title = canvas.title || options[:title]
        mime_type = DyiRails.mime_type(format)

        tag_parts = ['<img']
        tag_parts << " id=\"#{element_id}\"" if element_id
        tag_parts << ' src="data:'
        tag_parts << mime_type
        tag_parts << ";base64,\n"
        tag_parts << [canvas.string(format)].pack('m')[0..-2]
        tag_parts << '"'
        tag_parts << " type=\"#{mime_type}\""
        tag_parts << " class=\"#{class_name}\"" if class_name
        tag_parts << " width=\"#{canvas.real_width}\""
        tag_parts << " height=\"#{canvas.real_height}\""
        tag_parts << " alt=\"#{alt}\""
        tag_parts << " title=\"#{title}\"" if title
        tag_parts << " />"
        tag_parts.join
      else
        # output <object> tag with base64 encoding
        element_id = canvas.inner_id || options[:id]
        class_name = options[:class]
        alt = canvas.description || options[:alt] || 'dyi image'
        title = canvas.title || options[:title]
        mime_type = DyiRails.mime_type(format)

        tag_parts = ['<object']
        tag_parts << " id=\"#{element_id}\"" if element_id
        tag_parts << " data=\"data:"
        tag_parts << mime_type
        tag_parts << ";base64,\n"
        tag_parts << [canvas.string(format)].pack('m')[0..-2]
        tag_parts << "\""
        tag_parts << " type=\"#{mime_type}\""
        tag_parts << " class=\"#{class_name}\"" if class_name
        tag_parts << " width=\"#{canvas.real_width}\""
        tag_parts << " height=\"#{canvas.real_height}\""
        tag_parts << " title=\"#{title}\"" if title
        tag_parts << ">"
        tag_parts << alt
        tag_parts << "</object>"
        tag_parts.join
      end
    end

    # Returns a HTML +_img_+ element.
    # @option options [String] :id id of the HTML element
    # @option options [String] :class CSS class name of the HTML element
    # @option options [String] :alt equivalent content for those who cannot
    #   process images or who have image loading disabled. Default to 'dyi image'
    # @option options [String] :title title of the image
    # @option options [Integer] :width width of the image
    # @option options [Integer] :height height of the image
    # @option options [Symbol, String] :format format of the image. Default to
    #   +:svg+
    # @option options [String] :controller controller of Rails' application
    #   that process the image. Default to 'images'
    # @option options [String] :action action of Rails' application that process
    #   the image. Default to 'dyi'
    # @option options [String] :model_id id as a parameter passed to the Rails'
    #   application that process the image. Default to 'dyi'
    # @option options [String] other-options other options is passed to +url_for+
    #   method. See examples
    # @return [String] HTML +_img_+ element contains URI reference to the image
    # @example
    #   dyi_image_tag(:format => :png, :width => 200, :height => 150)
    #   # => <img width="200" height="150" alt="dyi image" src="/images/dyi/dyi.png" />
    #   
    #   dyi_image_tag(:format => :png, :width => 200, :height => 150, :id => 'emb',
    #                 :controller => 'teams', :action => 'emblem', :model_id => '1')
    #   # => <img id="emb" width="200" height="150" alt="dyi image" src="/teams/emblem/1.png" />
    #   
    #   dyi_image_tag(:format => :png, :width => 200, :height => 150, :id => 'emb',
    #                 :controller => 'teams', :action => 'emblem', :model_id => '1',
    #                 :color => 'red', :type => 'simple')
    #   # => <img id="emb" width="200" height="150" alt="dyi image"
    #   #         src="/teams/emblem/1.png?color=red&amp;type=simple" />
    def dyi_image_tag(options={})
      opt = options.clone
      element_id = opt.delete(:id)
      class_name = opt.delete(:class)
      alt = opt.delete(:alt) || 'dyi image'
      title = opt.delete(:title)
      width = opt.delete(:width)
      height = opt.delete(:height)

      opt[:controller] = 'images' unless opt[:controller]
      opt[:action] = 'dyi' unless opt[:action]
      opt[:id] = opt.delete(:model_id) || 'dyi'
      opt[:format] = 'svg' unless opt[:format]

      tag_parts = ['<img']
      tag_parts << " id=\"#{element_id}\"" if element_id
      tag_parts << " src=\"#{url_for(opt)}\""
      tag_parts << " class=\"#{class_name}\"" if class_name
      tag_parts << " width=\"#{width}\"" if width
      tag_parts << " height=\"#{height}\"" if height
      tag_parts << " alt=\"#{alt}\""
      tag_parts << " title=\"#{title}\"" if title
      tag_parts << " />"
      tag_parts.join
    end

    # Returns a HTML +_object_+ element.
    # @option options [String] :id id of the HTML element
    # @option options [String] :class CSS class name of the HTML element
    # @option options [String] :alt equivalent content for those who cannot
    #   process images or who have image loading disabled. Default to 'dyi image'
    # @option options [String] :title title of the image
    # @option options [Integer] :width width of the image
    # @option options [Integer] :height height of the image
    # @option options [Symbol, String] :format format of the image. Default to
    #   +:svg+
    # @option options [String] :controller controller of Rails' application
    #   that process the image. Default to 'images'
    # @option options [String] :action action of Rails' application that process
    #   the image. Default to <tt>'dyi'</tt>
    # @option options [String] :model_id id as a parameter passed to the Rails'
    #   application that process the image. Default to <tt>'dyi'</tt>
    # @option options [String] other-options other options is passed to +url_for+
    #   method. See examples
    # @return [String] HTML +_object_+ element contains URI reference to the
    #   image
    # @example
    #   dyi_object_tag(:width => 200, :height => 150)
    #   # => <object width="200" height="150" type="image/svg+xml"
    #   #            data="/images/dyi/dyi.svg">dyi image</object>
    #   
    #   dyi_object_tag(:format => :png, :width => 200, :height => 150,
    #                  :id => 'emb', :alt => 'an emblem of the team',
    #                  :controller => 'teams', :action => 'emblem', :model_id => '1')
    #   # => <object id="emb" width="200" height="150" type="image/svg+xml"
    #   #            data="/teams/emblem/1.png">an emblem of the team</object>
    #   
    #   dyi_object_tag(:format => :png, :width => 200, :height => 150,
    #                  :id => 'emb', :alt => 'an emblem of the team',
    #                  :controller => 'teams', :action => 'emblem', :model_id => '1',
    #                  :color => 'red', :type => 'simple')
    #   # => <object id="emb" width="200" height="150" type="image/svg+xml"
    #   #            data="/teams/emblem/1.png">an emblem of the team</object>
    def dyi_object_tag(options={})
      opt = options.clone
      element_id = opt.delete(:id)
      class_name = opt.delete(:class)
      alt = opt.delete(:alt) || 'dyi image'
      title = opt.delete(:title)
      width = opt.delete(:width)
      height = opt.delete(:height)
      mime_type = DyiRails.mime_type(opt[:format] || :svg)

      opt[:controller] = 'images' unless opt[:controller]
      opt[:action] = 'dyi' unless opt[:action]
      opt[:id] = opt.delete(:model_id) || 'dyi'
      opt[:format] = 'svg' unless opt[:format]

      tag_parts = ['<object']
      tag_parts << " id=\"#{element_id}\"" if element_id
      tag_parts << " data=\"#{url_for(opt)}\""
      tag_parts << " type=\"#{mime_type}\""
      tag_parts << " class=\"#{class_name}\"" if class_name
      tag_parts << " width=\"#{width}\"" if width
      tag_parts << " height=\"#{height}\"" if height
      tag_parts << " title=\"#{title}\"" if title
      tag_parts << ">"
      tag_parts << alt
      tag_parts << "</object>"
      tag_parts.join
    end
  end
end

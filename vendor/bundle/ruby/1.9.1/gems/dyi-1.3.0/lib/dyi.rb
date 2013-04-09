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

# Root namespace of DYI.
# @since 0.0.0
module DYI

  # DYI program version
  VERSION = '1.3.0'

  # URL of DYI Project
  # @since 0.0.2
  URL = 'http://open-dyi.org/'

  class << self

    # Draw a DYI's logo.
    # @option options [Canvas, Shape::ShapeGroup] :canvas a container element
    #   of the DYI's logo
    # @option options [Length] :width a width of the logo mark
    # @option options [Length] :height a height of the logo mark
    # @option options [Length] :left a x-coordinate of a left edge of the logo
    #   mark
    # @option options [Length] :top a y-coordinate of a top edge of the logo
    #   mark
    # @return [Canvas, Shape::ShapeGroup] a new Canvas object which logo mark is
    #   draw on if :canvas option is given, otherwise a new Shape::Group object
    #   which logo mark is on.
    # @since 1.3.0
    def logo(options = {})
      width = Length.new(options[:width] || 287)
      height = Length.new(options[:height] || 163)
      if options[:canvas]
        canvas = Shape::ShapeGroup.draw_on(options[:canvas])
        canvas.scale(width / 287, height / 163)
        canvas.translate(options[:left] || 0, options[:top] || 0)
      else
        canvas = Canvas.new(width, height)
      end
      Drawing::Brush.new(:color=>'#51ADE2').draw_closed_path(canvas, [287,0]) {|path|
        path.rline_to([0,162.637], [-39.41,0])
        path.rcurve_to([0,-5.191], [-1.729,-107.272], [-1.729,-107.272], [-2.594,102.295], [-2.813,107.272])
        path.rline_to([-3.246,0])
        path.rcurve_to([0,-4.977], [-1.728,-107.272], [-1.728,-107.272], [-2.595,102.513], [-2.595,107.272])
        path.rline_to([-3.245, 0])
        path.rcurve_to([-0.215,-4.54], [-1.729,-107.272], [-1.729,-107.272], [-2.813,102.943], [-2.813,107.272])
        path.rline_to([-3.46, 0], [0, -162.637])
      }
      Drawing::Brush.new(:color=>'#325BA8').draw_closed_path(canvas, [258.471,0]) {|path|
        path.rline_to([-52.793,97.971], [-0.078,64.666], [-57.073,0], [-0.071,-65.106], [-49.789,-97.531],[92.148,0])
        path.rcurve_to([-12.327,25.52], [-35.9,74.829], [-35.9,74.829], [27.034,-50.391], [40.013,-74.829])
        path.rline_to([4.322,0])
        path.rcurve_to([-11.461,24.221], [-37.414,78.289], [-37.414,78.289], [30.206,-55.798], [41.955,-78.289])
        path.rline_to([4.111,0])
        path.rcurve_to([-10.599,21.844], [-39.146,81.75], [-39.146,81.75], [33.306,-62.069], [43.687,-81.75])
      }
      Drawing::Brush.new(:color=>'#51ADE2', :rule => 'evenodd').draw_closed_path(canvas, [149.875,78.938]){|path|
        path.rcurve_to([0,13.193], [-2.379,25.52], [-7.353,36.552], [-11.894,20.114], [-20.112,27.249])
        path.rline_to([-0.216, 0])
        path.rcurve_to([-9.517,7.786], [-20.113,12.76], [-31.144,15.787], [-22.276,4.111], [-33.954,4.111], [-22.276,-0.651], [-28.98,-1.514])
        path.rline_to([-20.113, -2.815])
        path.rcurve_to([12.327,-1.077], [34.17,-4.322], [54.5,-15.784])
        path.rcurve_to([14.921,-8.219], [27.034,-21.627], [32.441,-33.524], [6.271,-20.543], [6.487,-20.543])
        path.rcurve_to([-0.217,0], [-1.08,8.649], [-7.137,20.114], [-18.167,24.654], [-32.873,32.003])
        path.rcurve_to([-25.953,13.411], [-54.067,13.84], [-61.421,13.84])
        path.rline_to([0, -3.241])
        path.rcurve_to([7.137,-0.215], [34.82,-1.729], [58.827,-15.355])
        path.rcurve_to([29.844,-14.921], [35.9,-49.526], [35.035,-48.661])
        path.rcurve_to([0.866,-0.866], [-6.487,33.303], [-36.117,46.714])
        path.rcurve_to([-23.791,12.327], [-50.608,12.976], [-57.745,12.976])
        path.rline_to([0, -3.246])
        path.rcurve_to([6.92,-0.211], [33.307,-1.942], [55.15,-14.488])
        path.rcurve_to([26.168,-13.193], [31.358,-41.955], [31.358,-43.254])
        path.rcurve_to([0,1.299], [-6.487,29.631], [-32.44,41.311])
        path.rcurve_to([-21.628,11.242], [-47.148,12.108], [-54.068,12.108])
        path.rline_to([0,-132.574])
        path.rline_to([27.25, -4.326])
        path.rcurve_to([10.381,-1.731], [22.06,-2.378], [34.604,-2.378], [21.194,0.864], [31.36,3.677], [19.464,6.92], [27.25,12.975], [16.868,16.006], [21.843,26.819], [7.568,22.924], [7.568,35.467])
      }
      canvas
    end
  end
end

%w(

util
dyi/util
dyi/length
dyi/coordinate
dyi/color
dyi/painting
dyi/font
dyi/matrix
dyi/type
dyi/svg_element
dyi/element
dyi/canvas
dyi/shape
dyi/drawing
dyi/event
dyi/animation
dyi/script
dyi/stylesheet
dyi/formatter
dyi/chart

).each do |file_name|
  require File.join(File.dirname(__FILE__), file_name)
end

if defined? IRONRUBY_VERSION
  require File.join(File.dirname(__FILE__), 'ironruby')
end

# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

canvas = DYI::Canvas.new(500, 280)
canvas.title = 'Rainbow'
canvas.description = 'This image is a sample of DYI which uses a radial gradient.'

logo_container = DYI::Shape::ShapeGroup.draw_on(canvas)
DYI.logo(:canvas => logo_container,
         :width => 287,
         :height => 163,
         :top => 100,
         :left => 160)

gradient = DYI::Drawing::ColorEffect::RadialGradient.new([1,1.2], 1.2)
gradient.add_color_opacity(0.72, 'violet', 0)
gradient.add_color_opacity(0.74, 'violet', 0.5)
gradient.add_color_opacity(0.78, 'indigo', 0.5)
gradient.add_color_opacity(0.82, 'blue', 0.5)
gradient.add_color_opacity(0.86, 'green', 0.5)
gradient.add_color_opacity(0.9, 'yellow', 0.5)
gradient.add_color_opacity(0.94, 'orange', 0.5)
gradient.add_color_opacity(0.98, 'red', 0.5)
gradient.add_color_opacity(1, 'red', 0)

pen = DYI::Drawing::Brush.new(:color => gradient)
pen.draw_rectangle(canvas, [0,0], 500, 280)

canvas.save('output/rainbow.svg')

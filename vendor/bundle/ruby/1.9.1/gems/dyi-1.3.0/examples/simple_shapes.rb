# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

canvas = DYI::Canvas.new(500, 500)

pen = DYI::Drawing::Pen.new(:color => 'blue')
pen.draw_rectangle(canvas, [30, 30], 30, 30)

brush = DYI::Drawing::Brush.new(:color => 'rgb(255,255,127)', :width => 0)
center_point = DYI::Coordinate.new(100, 45)
brush.draw_circle(canvas, center_point, 20)

pen = DYI::Drawing::Pen.new(:color => '#CCFFCC', :width => 5)
pen.draw_line(canvas, [150,70], [80,140])

canvas.save 'output/simple_shape.svg'

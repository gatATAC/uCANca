# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

canvas = DYI::Canvas.new(300, 250)

pen = DYI::Drawing::Pen.new(:color => 'red')
pen.draw_rectangle(canvas, [20, 20], 240, 100)
pen.draw_rectangle(canvas, [20, 140], 240, 100, :css_class => 'sample-css')
pen = DYI::Drawing::Brush.new(:color => 'red')
pen.draw_circle(canvas, [120, 130], 40)
pen.draw_circle(canvas, [230, 130], 40, :css_class => 'transparent')

css =<<-EOS
rect {
  fill: yellow;
  stroke-dasharray: 10 5;
}
rect.sample-css {
  fill: skyblue;
  stroke: blue;
  stroke-width: 5;
}
.transparent {
  fill: none;
  stroke: green;
  stroke-width: 3;
}
EOS

canvas.add_stylesheet(css)

canvas.save 'output/css.svg'

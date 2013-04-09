# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

canvas = DYI::Canvas.new(400, 300)

rect = DYI::Drawing::Brush.new(:color=>'#51ADE2').draw_rectangle(canvas, [10,10], 300, 200)
rect.add_painting_animation(:from => {:fill => '#51ADE2'},
                            :to => {:fill => 'red'},
                            :duration => 3,
                            :begin_event => DYI::Event.mouseover(rect),
                            :end_event => DYI::Event.mouseout(rect),
                            :fill => 'freeze')
text = DYI::Drawing::Brush.new.draw_text(canvas,
                                         [100,250],
                                         'click me!',
                                         :show_border => true,
                                         :border_color=>'#325BA8',
                                         :padding => 8,
                                         :border_rx => 10,
                                         :border_width => 3,
                                         :background_color=>'#A5C7F8')
rect.add_painting_animation(:to => {:fill => 'green'},
                            :begin_event => DYI::Event.click(text),
                            :fill => 'freeze')

canvas.save('output/simple_animation.svg')

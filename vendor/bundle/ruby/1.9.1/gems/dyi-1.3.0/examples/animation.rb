# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

canvas = DYI::Canvas.new(250, 140)
canvas.title = 'Animation Icons without Script'
canvas.description = 'This image is a sample of DYI which uses SVG animation.'

# Left-Hand Icon
icon1 = DYI::Shape::ShapeGroup.draw_on(canvas)
pen = DYI::Drawing::Pen.new(:stroke_width => 6, :stroke_linecap => 'round')
pen.color = '#DDD'
line = pen.draw_line(icon1, [10,0], [18,0])
line.add_painting_animation(:from => {:stroke => '#DDD'},
                            :relays => [{:stroke => '#DDD'}, {:stroke => '#333'}, {:stroke => '#DDD'}],
                            :to => {:stroke => '#DDD'},
                            :relay_times => [0.125, 0.125, 0.75],
                            :duration => 1,
                            :repeat_count => 0)
line = pen.draw_line(icon1, [10,0], [18,0])
line.rotate(45)
line.add_painting_animation(:from => {:stroke => '#DDD'},
                            :relays => [{:stroke => '#DDD'}, {:stroke => '#333'}, {:stroke => '#DDD'}],
                            :to => {:stroke => '#DDD'},
                            :relay_times => [0.25, 0.25, 0.825],
                            :duration => 1,
                            :repeat_count => 0)
line = pen.draw_line(icon1, [10,0], [18,0])
line.rotate(90)
line.add_painting_animation(:from => {:stroke => '#DDD'},
                            :relays => [{:stroke => '#DDD'}, {:stroke => '#333'}],
                            :to => {:stroke => '#DDD'},
                            :relay_times => [0.375, 0.375, 1],
                            :duration => 1,
                            :repeat_count => 0)
line = pen.draw_line(icon1, [10,0], [18,0])
line.rotate(135)
line.add_painting_animation(:from => {:stroke => '#BBB'},
                            :relays => [{:stroke => '#DDD'}, {:stroke => '#DDD'}, {:stroke => '#333'}],
                            :to => {:stroke => '#BBB'},
                            :relay_times => [0.125, 0.5, 0.5],
                            :duration => 1,
                            :repeat_count => 0)
pen.color = '#999'
line = pen.draw_line(icon1, [10,0], [18,0])
line.rotate(180)
line.add_painting_animation(:from => {:stroke => '#999'},
                            :relays => [{:stroke => '#DDD'}, {:stroke => '#DDD'}, {:stroke => '#333'}],
                            :to => {:stroke => '#999'},
                            :relay_times => [0.25, 0.625, 0.625],
                            :duration => 1,
                            :repeat_count => 0)
pen.color = '#777'
line = pen.draw_line(icon1, [10,0], [18,0])
line.rotate(225)
line.add_painting_animation(:from => {:stroke => '#777'},
                            :relays => [{:stroke => '#DDD'}, {:stroke => '#DDD'}, {:stroke => '#333'}],
                            :to => {:stroke => '#777'},
                            :relay_times => [0.375, 0.75, 0.75],
                            :duration => 1,
                            :repeat_count => 0)
pen.color = '#555'
line = pen.draw_line(icon1, [10,0], [18,0])
line.rotate(270)
line.add_painting_animation(:from => {:stroke => '#555'},
                            :relays => [{:stroke => '#DDD'}, {:stroke => '#DDD'}, {:stroke => '#333'}],
                            :to => {:stroke => '#555'},
                            :relay_times => [0.5, 0.875, 0.875],
                            :duration => 1,
                            :repeat_count => 0)
pen.color = '#333'
line = pen.draw_line(icon1, [10,0], [18,0])
line.rotate(315)
line.add_painting_animation(:from => {:stroke => '#333'},
                            :relays => [{:stroke => '#DDD'}, {:stroke => '#DDD'}],
                            :to => {:stroke => '#333'},
                            :relay_times => [0.625, 1],
                            :duration => 1,
                            :repeat_count => 0)
icon1.translate(70,70)

# Right-Hand Icon
icon2 = DYI::Shape::ShapeGroup.draw_on(canvas)
brush = DYI::Drawing::Brush.new(:color => '#08A')
brush.draw_closed_path(icon2, [-14.489, -3.882]){|path|
  path.arc_to([12.99, -7.5], 15, 15)
  path.line_to([17.321, -10], [14.5, 0], [4.33, -2.5], [8.66, -5])
  path.arc_to([-9.397, -3.42], 10, 10, 0, false, false)
}
brush.draw_closed_path(icon2, [14.489, 3.882]){|path|
  path.arc_to([-12.99, 7.5], 15, 15)
  path.line_to([-17.321, 10], [-14.5, 0], [-4.33, 2.5], [-8.66, 5])
  path.arc_to([9.397, 3.42], 10, 10, 0, false, false)
}
icon2.add_transform_animation(:rotate,
                              :from => 0,
                              :to => 360,
                              :duration => 1.5,
                              :repeat_count => 0,
                              :additive => 'sum')
icon2.translate(180,70)

canvas.save('output/animation.svg')

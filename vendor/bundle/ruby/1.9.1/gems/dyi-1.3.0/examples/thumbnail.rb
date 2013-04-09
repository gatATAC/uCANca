# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

include DYI::Script::EcmaScript::DomLevel2

canvas = DYI::Canvas.new(500, 280)

base_pen = DYI::Drawing::Pen.new(:font => {:size => '14pt'})

symbols = []

symbol = DYI::Shape::GraphicalTemplate.new(400,170)
pen = DYI::Drawing::Pen.new(:color => 'blue', :width => 10)
pen.draw_rectangle(symbol, [50, 40], 300, 90, :rx => 30)
base_pen.draw_text(symbol, [200, 25], 'Rounded Rectangle', :text_anchor => 'middle')
base_pen.draw_text(symbol, [200, 160], 'page 1', :text_anchor => 'middle')
symbols << symbol

symbol = DYI::Shape::GraphicalTemplate.new(400,170)
pen = DYI::Drawing::Pen.new(:color => 'red', :width => 10)
pen.draw_ellipse(symbol, [200, 85], 150, 45)
base_pen.draw_text(symbol, [200, 25], 'Ellipse', :text_anchor => 'middle')
base_pen.draw_text(symbol, [200, 160], 'page 2', :text_anchor => 'middle')
symbols << symbol

symbol = DYI::Shape::GraphicalTemplate.new(400,170)
pen = DYI::Drawing::Pen.new(:color => 'green', :width => 10)
pen.draw_polygon(symbol, [[200, 40], [150, 60], [150, 110], [200, 130], [250, 110], [250, 60]])
base_pen.draw_text(symbol, [200, 25], 'Hexagon', :text_anchor => 'middle')
base_pen.draw_text(symbol, [200, 160], 'page 3', :text_anchor => 'middle')
symbols << symbol

symbol = DYI::Shape::GraphicalTemplate.new(400,170)
pen = DYI::Drawing::Pen.new(:color => 'orange', :width => 10)
pen.draw_path(symbol, [100, 85]){|path|
  path.quadratic_curve_to([150, 0], [200, 85], [300, 85])
}
base_pen.draw_text(symbol, [200, 25], 'Wave', :text_anchor => 'middle')
base_pen.draw_text(symbol, [200, 160], 'page 4', :text_anchor => 'middle')
symbols << symbol

symbol = DYI::Shape::GraphicalTemplate.new(400,170)
brush = DYI::Drawing::Brush.cyan_brush
brush.draw_circle(symbol, [200, 85], 50).add_transform_animation(:translate,
      :from => [-100, 0],
      :relays => [[100,0]],
      :to => [-100, 0],
      :relayTimes => [0.5],
      :duration => 3,
      :calc_mode => 'spline',
      :key_splines => [0.6, 0, 0.4, 1, 0.6, 0, 0.4, 1],
      :repeat_count => 0)
base_pen.draw_text(symbol, [200, 25], 'Animation Circle', :text_anchor => 'middle')
base_pen.draw_text(symbol, [200, 160], 'page 5', :text_anchor => 'middle')
symbols << symbol

current_use = symbols.first.instantiate_on(canvas, [50, 10], :width => 400, :height => 170)
base_pen.draw_rectangle(canvas, [50, 10], 400, 170)

symbols.each_with_index do |symbol, i|
  group = DYI::Shape::ShapeGroup.draw_on(canvas)
  rect = base_pen.draw_rectangle(group, [105  + i * 60, 190], 50, 50)
  use = symbol.instantiate_on(group, [105  + i * 60, 190], :width => 50, :height => 50)
  group.skew_y(35, [105 + i * 60, 190])
  rect.add_event_listener(:click, <<-SCRIPT)
    var currentUse = #{get_element(current_use)};
    currentUse.setAttributeNS('http://www.w3.org/1999/xlink', 'href', "##{symbol.id = canvas.publish_shape_id}");
  SCRIPT
end

canvas.save('output/thumbnail.svg')

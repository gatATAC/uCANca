# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

include DYI::Script::EcmaScript::DomLevel2

path_points = [
  [197, 42.141], [419.42, 172.747], [197, 306.472],
  [241.055, 264.061], [374, 172.748], [241.055, 84.553]
]
ctrl_points = [
  [262.211, 42.141], [419.42, 27.495], [419.42, 323.496], [260.69, 306.472],
  [270.044, 264.061], [374, 272.829], [374, 75.829], [269.211, 84.553]
]

canvas = DYI::Canvas.new(625, 350)
canvas.title = 'Letter D'
canvas.description = 'This image is a sample of DYI which is drawn Bezier curves.'

pen = DYI::Drawing::Pen.new(:width => 0, :color => nil)
rect = pen.draw_rectangle(canvas, [1,1], canvas.width - 2, canvas.height - 2)

letter = pen.draw_path(canvas, path_points[0]){|path|
  path.curve_to(ctrl_points[0], ctrl_points[1], path_points[1])
  path.curve_to(ctrl_points[2], ctrl_points[3], path_points[2])
  path.close_path
  path.move_to(path_points[3])
  path.curve_to(ctrl_points[4], ctrl_points[5], path_points[4])
  path.curve_to(ctrl_points[6], ctrl_points[7], path_points[5])
  path.close_path
  path.set_marker(:all, :circle, :size => 5)
}

lines = []
lines << pen.draw_line(canvas, path_points[0], ctrl_points[0])
lines << pen.draw_line(canvas, path_points[1], ctrl_points[1])
lines << pen.draw_line(canvas, path_points[1], ctrl_points[2])
lines << pen.draw_line(canvas, path_points[2], ctrl_points[3])
lines << pen.draw_line(canvas, path_points[3], ctrl_points[4])
lines << pen.draw_line(canvas, path_points[4], ctrl_points[5])
lines << pen.draw_line(canvas, path_points[4], ctrl_points[6])
lines << pen.draw_line(canvas, path_points[5], ctrl_points[7])

circles = ctrl_points.map do |ctrl_pt|
  circle = pen.draw_circle(canvas, ctrl_pt, 7.5)
  circle.set_event(nil)
  circle
end

dragging = DYI::Script::EcmaScript::EventListener.new(<<SCRIPT)
  if(target_id == null) return;
  var x = evt.pageX;
  var y = evt.pageY;
  circles[target_id].cx.baseVal.value = x;
  circles[target_id].cy.baseVal.value = y;
  lines[target_id].x2.baseVal.value = x;
  lines[target_id].y2.baseVal.value = y;
  letter.pathSegList.getItem(command_ids[target_id])['x' + (target_id % 2 == 0 ? '1' : '2')] = x;
  letter.pathSegList.getItem(command_ids[target_id])['y' + (target_id % 2 == 0 ? '1' : '2')] = y;
SCRIPT

end_drag = DYI::Script::EcmaScript::EventListener.new(<<SCRIPT)
  if(target_id == null) return;
  circles[target_id].className.baseVal = '';
  lines[target_id].className.baseVal = '';
  target_id = null;
SCRIPT

canvas.add_script(<<SCRIPT)
  var target_id = null;
  var command_ids = [1, 1, 2, 2, 5, 5, 6, 6];
  var letter, lines, circles
SCRIPT

canvas.add_initialize_script(<<SCRIPT)
  letter = #{get_element(letter)};
  lines = [#{lines.map{|l| get_element(l)}.join(',')}];
  circles = [#{circles.map{|c| get_element(c)}.join(',')}];
SCRIPT

circles.each_with_index do |circle, i|
  start_drag = DYI::Script::EcmaScript::EventListener.new(<<-SCRIPT)
    if(target_id != null) return;
    target_id = #{i};
    circles[target_id].className.baseVal = 'target';
    lines[target_id].className.baseVal = 'target';
  SCRIPT

  circle.add_event_listener(:mousedown, start_drag)
  circle.add_event_listener(:mousemove, dragging)
  circle.add_event_listener(:mouseup, end_drag)
end
rect.add_event_listener(:mousemove, dragging)
rect.add_event_listener(:mouseup, end_drag)

canvas.add_stylesheet(<<CSS)
path {
  fill: #C3DAFF;
  stroke: #666666;
  stroke-width: 3;
}
svg > circle {
  fill: white;
  stroke: #336699;
  stroke-width: 1;
  cursor: move;
}
marker circle{
  fill: #666666
}
line {
  stroke: #003DA2;
  stroke-width: 2;
  stroke-dasharray: 6,4;
}
circle.target{
  fill: #33CCFF;
}
line.target{
  stroke: #33CCFF;
}
CSS

canvas.save('output/letter.svg')

# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

include DYI::Script::EcmaScript::DomLevel2

settings = {
    :hour => {:center => [250, 60], :rx => 220, :ry => 20},
    :minute => {:center => [250, 91], :rx => 220, :ry => 32},
    :second => {:center => [250, 122], :rx => 220, :ry => 44}}
settings.each do |key, value|
  value[:label_position] = DYI::Coordinate.new(value[:center][0],
                                               value[:center][1] + value[:ry] + 10)
end

canvas = DYI::Canvas.new(500, 200)
canvas.title = 'Circle Clock'
canvas.description = 'This image is a sample of DYI which uses a client script.'

pen = DYI::Drawing::Pen.new

gradient = DYI::Drawing::ColorEffect::LinearGradient.new([0,0],[0,1])
gradient.add_color(0, 'gainsboro')
gradient.add_color(1, 'grey')
line_pen = DYI::Drawing::Pen.new
line_pen.color = gradient

setting = settings[:second]
sec_group = DYI::Shape::ShapeGroup.draw_on(canvas)
line_pen.draw_ellipse(sec_group, setting[:center], setting[:rx], setting[:ry])
60.times do |i|
  pen.draw_text(sec_group, [0, 0], i.to_s,
                :text_anchor => 'middle',
                :css_class => i % 5 == 0 ? 'large' : 'small')
end
pen.draw_text(canvas, setting[:label_position], 'seconds',
              :text_anchor => 'middle',
              :css_class => 'label')

setting = settings[:minute]
min_group = DYI::Shape::ShapeGroup.draw_on(canvas)
line_pen.draw_ellipse(min_group, setting[:center], setting[:rx], setting[:ry])
60.times do |i|
  pen.draw_text(min_group, [0, 0], i.to_s,
                :text_anchor => 'middle',
                :css_class => i % 5 == 0 ? 'large' : 'small')
end
pen.draw_text(canvas, setting[:label_position], 'minutes',
              :text_anchor => 'middle',
              :css_class => 'label')

setting = settings[:hour]
hour_group = DYI::Shape::ShapeGroup.draw_on(canvas)
line_pen.draw_ellipse(hour_group, setting[:center], setting[:rx], setting[:ry])
12.times do |i|
  pen.draw_text(hour_group, [0, 0], (i + 1).to_s,
                :text_anchor => 'middle',
                :css_class => 'large')
end
pen.draw_text(canvas, setting[:label_position], 'hours',
              :text_anchor => 'middle',
              :css_class => 'label')
ap_label = pen.draw_text(canvas, setting[:label_position] + [18, -10], 'A.M.',
                         :css_class => 'label')

canvas.add_initialize_script(<<-SCRIPT)
  var hourTexts = #{get_element(hour_group)}.getElementsByTagName('text');
  var minTexts = #{get_element(min_group)}.getElementsByTagName('text');
  var secTexts = #{get_element(sec_group)}.getElementsByTagName('text');
  var apLabel = #{get_element(ap_label)};
  var hour = -1, minute = -1, second = -1;

  function rewrite(){
    var currentTime = new Date();
    var text, i, angle, baseSize;

    if(hour != currentTime.getHours()){
      hour = currentTime.getHours();
      for(i = 0; i < 12; i++){
        text = hourTexts.item(i);
        angle = Math.PI / 6 * (hour % 12 - i - 1);
        text.setAttribute('x', #{settings[:hour][:rx]} * Math.sin(angle) + #{settings[:hour][:center][0]});
        text.setAttribute('y', #{settings[:hour][:ry]} * Math.cos(angle) + #{settings[:hour][:center][1]});
        text.setAttribute('opacity', (Math.cos(angle) + 1) * 0.375  + 0.25);
        if(hour % 12 == i + 1){
          text.setAttribute('font-size', '20pt');
        }
        else{
          text.setAttribute('font-size', (16 * 200 / (300 - 100 * Math.cos(angle))).toString() + 'pt');
        }
      }
      apLabel.childNodes.item(0).data = hour < 12 ? 'A.M.' : 'P.M.';
    }

    if(minute != currentTime.getMinutes()){
      minute = currentTime.getMinutes();
      for(i = 0; i < 60; i++){
        text = minTexts.item(i);
        angle = Math.PI / 30 * (minute - i);
        text.setAttribute('x', #{settings[:minute][:rx]} * Math.sin(angle) + #{settings[:minute][:center][0]});
        text.setAttribute('y', #{settings[:minute][:ry]} * Math.cos(angle) + #{settings[:minute][:center][1]});
        text.setAttribute('opacity', (Math.cos(angle) + 1) * 0.375  + 0.25);
        if(minute == i){
          text.setAttribute('font-size', '20pt');
        }
        else{
          baseSize = text.className.baseVal == 'large' ? 12 : 6;
          text.setAttribute('font-size', (baseSize * 200 / (300 - 100 * Math.cos(angle))).toString() + 'pt');
        }
      }
    }

    if(second != currentTime.getSeconds()){
      second = currentTime.getSeconds();
      for(i = 0; i < 60; i++){
        text = secTexts.item(i);
        angle = Math.PI / 30 * (second - i);
        text.setAttribute('x', #{settings[:second][:rx]} * Math.sin(angle) + #{settings[:second][:center][0]});
        text.setAttribute('y', #{settings[:second][:ry]} * Math.cos(angle) + #{settings[:second][:center][1]});
        text.setAttribute('opacity', (Math.cos(angle) + 1) * 0.375  + 0.25);
        if(second == i){
          text.setAttribute('font-size', '20pt');
        }
        else{
          baseSize = text.className.baseVal == 'large' ? 12 : 6;
          text.setAttribute('font-size', (baseSize * 200 / (300 - 100 * Math.cos(angle))).toString() + 'pt');
        }
      }
    }
  }

  rewrite();
  setInterval(rewrite, 250);
SCRIPT

canvas.reference_stylesheet_file('http://fonts.googleapis.com/css?family=Great+Vibes')

canvas.add_stylesheet(<<-CSS)
text {
  font-family: 'Great Vibes', cursive;
}
text.large {
  font-weight: bold;
}
text.label {
  font-size: 10pt;
  text-decoration: underline;
}
CSS

canvas.save('output/clock.svg')

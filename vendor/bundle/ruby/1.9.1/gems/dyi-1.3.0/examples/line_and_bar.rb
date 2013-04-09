# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

reader = DYI::Chart::CsvReader.read('data/money.csv',
          :data_types => [:string, :number, :number, :string],
          :schema => [:name, :value, :value, :color],
          :row_range => (1..-1))
chart = DYI::Chart::LineChart.new(750,420,
          :use_y_second_axises => [false, true],
          :chart_margins => {:top => 30, :left => 80, :right => 65, :bottom => 55},
          :axis_format => '#,##0',
          :axis_settings => {:min => 800000},
          :max_x_label_count => 20,
          :data_columns => [0, 1],
          :chart_types => [:bar, :line],
          :line_width => 3,
          :show_dropshadow => true,
          :show_legend => false,
          :show_markers => true,
          :markers => [:circle])
chart.load_data reader

pen = DYI::Drawing::PenBase.new
pen.draw_text(chart.canvas, [10, 18], '(bilion yen)')
pen.draw_text(chart.canvas, [745, 18], '(bilion yen)', :text_anchor => 'end')
pen.draw_text(chart.canvas, [375, 21], 'Japanese Money Statistics',
          :text_anchor => 'middle',
          :font => {:font_family => 'sans-serif', :size => '16pt', :weight => 'bold'})

DYI::Drawing::Brush.new(:color => '#008000').draw_rectangle(chart.canvas, [70,395], 15, 15)
pen.draw_text(chart.canvas, [90,400], "Money Supply\n(before 2003; left axis)")
DYI::Drawing::Brush.new(:color => '#ffa500').draw_rectangle(chart.canvas, [255,395], 15, 15)
pen.draw_text(chart.canvas, [275,400], "Money Stock\n(since 2004; left axis)")
DYI::Drawing::Pen.new(:color => '#ff6600', :width => 3).draw_line(chart.canvas, [440,403], [455,403])
pen.draw_text(chart.canvas, [460,408], 'Monetary Base (right axis)')

chart.save('output/line_and_bar.svg')

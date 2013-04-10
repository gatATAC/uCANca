# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

gr = DYI::Drawing::ColorEffect::LinearGradient.new([0,0],[0,1])
gr.add_color(0, '#8FD3F5')
gr.add_color(1, '#D5EEF2')

chart = DYI::Chart::LineChart.new 720,300,
#  :represent_3d => true,
  :axis_format => '#,##0',
  :use_y_second_axises => [false, true, false],
  :chart_types => [:line, :area, :line],
  :x_axis_format => '%Y/%m/%d',
  :axis_font => {:font_family => 'HGPGOTHICM', :size => 12},
  :show_legend => true,
#  :axis_settings => {:min=>4000, :max=> 16000},
  :chart_colors => ['#F68C23', gr, '#89C549'],
  :line_width => 3,
  :legend_font => {},
  :legend_texts => ['Constant value (left axis)', 'Net Assets (right axis)', 'Constant value of Dividend  Reinvestment (left axis)']

reader = DYI::Chart::ExcelReader.read('data/03311056.xlsx', :sheet => 'Sheet2', :schema => [:name, :value, :value, :profit, :value], :column_range => 1..5, :row_range => 2..-1 )
chart.load_data reader

chart.save 'output/line_chart.svg'
chart.save 'output/line_chart.xaml', :xaml
chart.save 'output/line_chart.eps', :eps
chart.save 'output/line_chart.emf', :emf if defined? IRONRUBY_VERSION

# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

# Nominal GDP of Asian Countries (2010)
chart_data = [['China', 5878],
              ['Japan', 5459],
              ['India', 1538],
              ['South Koria', 1007],
              ['Other Countries', 2863]]
reader = DYI::Chart::ArrayReader.read(chart_data, :schema => [:name, :value])

# Creates the Pie Chart
chart = DYI::Chart::PieChart.new(500,240,
          :center_point => [130, 130],
          :legend_point => [250, 80],
          :chart_radius_x => 100,
          :show_data_label => false,
          :represent_3d => true,
          :_3d_settings => {:dy => 20},
          :baloon_format => "{?name}\n{?value:#,0}",
          :legend_format => "{?name}\t{!e}{?value:#,0}\t{!e}({?percent:0.0%})",
          :chart_stroke_color => 'white',
          :background_image_file => {:path => 'external_files/asian_map.png', :content_type => 'image/png'},
          :background_image_opacity => 0.3)
chart.load_data(reader)
DYI::Drawing::Pen.black_pen.draw_text(chart.canvas,
          [250, 40],
          'Nominal GDP of Asian Countries (2010)',
          :text_anchor => 'middle',
          :font => {:font_family => 'sans-serif', :size => '14pt', :weight => 'bold'})

chart.save('output/pie_chart.svg')

# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

canvas = DYI.logo

canvas.save('output/logo.svg')
canvas.save('output/logo.eps', :eps)

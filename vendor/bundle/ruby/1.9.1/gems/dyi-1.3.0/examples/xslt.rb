# -*- encoding: UTF-8 -*-

require 'rubygems'
require 'dyi'

canvas = DYI.logo
canvas.reference_stylesheet_file('../external_files/xslt.xsl', 'text/xsl')

canvas.save('output/xslt.svg')

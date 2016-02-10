# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
Mime::Type.register "image/svg+xml", :svg
Mime::Type.register "text/x-c", :c
Mime::Type.register "text/x-c", :h
Mime::Type.register "application/xml", :cdp
Mime::Type.register "application/xml", :xcos
Mime::Type.register "application/xml", :iox
Mime::Type.register "text/plain", :iocsv
Mime::Type.register "application/xls", :ioxls
Mime::Type.register "application/xls", :xls
Mime::Type.register "text/plain", :gv
#Mime::Type.register 'text/vnd.graphviz', :gv
Mime::Type.register "application/xml", :tree
Mime::Type.register "text/plain", :a2l
Mime::Type.register "text/plain", :par
Mime::Type.register "application/xml", :xdi
Mime::Type.register "text/javascript", :sim

Paperclip.options[:content_type_mappings] = {
  :xdi => 'application/xml'
}
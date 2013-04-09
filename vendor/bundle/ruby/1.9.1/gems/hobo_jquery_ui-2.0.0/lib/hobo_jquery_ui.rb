module HoboJqueryUi
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end

  EDIT_LINK_BASE = "https://github.com/Hobo/hobodoc/edit/master/hobo_jquery_ui"

  require 'hobo_jquery_ui/railtie' if defined?(Rails)

  class Engine < ::Rails::Engine
  end
end

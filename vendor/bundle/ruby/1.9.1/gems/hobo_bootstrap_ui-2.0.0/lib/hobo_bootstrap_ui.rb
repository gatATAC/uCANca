# Sub dependencies written in the gemspec are not loaded by default:
#   http://stackoverflow.com/questions/6960078
# We need to require them here, so we can load the JS from bootstrap

require 'bootstrap-datepicker-rails'

module HoboBootstrapUi

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  @@root = Pathname.new File.expand_path('../..', __FILE__)
  def self.root; @@root; end

  EDIT_LINK_BASE = "https://github.com/Hobo/hobo/edit/bootstrap_template/hobo_bootstrap"

  require 'hobo_bootstrap_ui/railtie' if defined?(Rails)

  class Engine < ::Rails::Engine
  end
end

require 'hobo'
require 'rails'
require 'rails/generators'


module Hobo
  class Engine < Rails::Engine

    ActiveSupport.on_load(:before_configuration) do
      h = config.hobo = ActiveSupport::OrderedOptions.new
      h.app_name = self.class.name.split('::').first.underscore.titleize
      h.developer_features = Rails.env.in?(["development", "test"])
      h.routes_path = Pathname.new File.expand_path('config/hobo_routes.rb', Rails.root)
      h.rapid_generators_path = Pathname.new File.expand_path('lib/hobo/rapid/generators', Hobo.root)
      h.auto_taglibs_path = Pathname.new File.expand_path('app/views/taglibs/auto', Rails.root)
      h.read_only_file_system = !!ENV['HEROKU_TYPE']
      h.show_translation_keys = false
      h.dryml_only_templates = false
      h.stable_cache_store = nil
    end

    ActiveSupport.on_load(:action_controller) do
      require 'hobo/extensions/action_controller/hobo_methods'
      require 'hobo/extensions/action_mailer/helper'
    end

    ActiveSupport.on_load(:active_record) do
      require 'hobo/extensions/active_record/associations/association'
      require 'hobo/extensions/active_record/associations/collection'
      require 'hobo/extensions/active_record/associations/proxy'
      require 'hobo/extensions/active_record/associations/reflection'
      require 'hobo/extensions/active_record/hobo_methods'
      require 'hobo/extensions/active_record/permissions'
      require 'hobo/extensions/active_record/associations/scope'
      require 'hobo/extensions/active_record/relation_with_origin'
      require 'hobo/extensions/active_model/name'
      require 'hobo/extensions/active_model/translation'
      require 'hobo/extensions/active_support/cache/file_store'
      # added legacy namespace for backward compatibility
      # TODO: remove the following line if Hobo::VERSION > 1.3.x
      Hobo::ViewHints = Hobo::Model::ViewHints
    end

    ActiveSupport.on_load(:action_view) do
      require 'hobo/extensions/action_view/tag_helper'
      require 'hobo/extensions/action_view/translation_helper'
    end

    ActiveSupport.on_load(:before_initialize) do
      require 'hobo/undefined'
      HoboFields.never_wrap(Hobo::Undefined)
      h = config.hobo
      Dryml::DrymlGenerator.enable([h.rapid_generators_path], h.auto_taglibs_path)
    end

    initializer 'hobo.i18n' do |app|
      require 'hobo/extensions/i18n' if app.config.hobo.show_translation_keys
    end

    initializer 'hobo.routes' do |app|
      h = app.config.hobo
      # generate at first boot, so no manual generation is required
      unless File.exists?(h.routes_path)
        raise Hobo::Error, "No #{h.routes_path} found!" if h.read_only_file_system
        Rails::Generators.invoke('hobo:routes', %w[-f -q])
      end
      app.routes_reloader.paths << h.routes_path
      app.config.to_prepare do
        Rails::Generators.invoke('hobo:routes', %w[-f -q])
      end
    end

    initializer 'hobo.dryml' do |app|
      unless app.config.hobo.read_only_file_system
        app.config.to_prepare do
          Dryml::DrymlGenerator.run
        end
      end
    end

    initializer 'hobo.cache' do |app|
      if app.config.hobo.stable_cache_store
        Hobo.stable_cache = ActiveSupport::Cache.lookup_store(app.config.hobo.stable_cache_store)
      else
        Hobo.stable_cache = Rails.cache
      end
    end

    # hobo_field's rich types let you refer to rich type with symbols:
    #     fields do; shout :loud; end.
    # The problem comes if you never use LoudText in your code, rails
    # autoloader will never kick in and autoload
    # app/rich_types/loud_text.rb, so let's preemptively require
    # everything in that directory.
    initializer 'hobo.rich_types' do |app|
      Dir["#{Rails.root}/app/rich_types/*"].each do |file|
        require_dependency file
      end
    end

  end
end

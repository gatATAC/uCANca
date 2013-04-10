module Dryml
  class Railtie < Rails::Railtie

    ActiveSupport.on_load(:before_initialize) do |app|
      require 'dryml'
      require 'dryml/template'
      require 'dryml/dryml_generator'
      require 'dryml/railtie/page_tag_resolver'
    end

    ActiveSupport.on_load(:action_controller) do
      require 'dryml/extensions/action_controller/dryml_methods'
    end

    ActiveSupport.on_load(:action_view) do
      ActionView::Template.register_template_handler("dryml", Dryml::Railtie::TemplateHandler)
    end

    initializer 'dryml' do |app|
      app.config.to_prepare do
        Dryml.clear_cache
        Dryml::Taglib.clear_cache
      end
    end

  end
end

# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "dyi_rails"
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mamoru Yuo"]
  s.date = "2012-04-06"
  s.description = "    \"DYI for Rails\" is a library for use DYI on Rails.\n    \"DYI for Rails\" provides some helpers and module for drawing a image of DYI.\n"
  s.email = "dyi_support@sound-f.jp"
  s.homepage = "http://sourceforge.net/projects/dyi-rails/"
  s.licenses = ["GPL-3"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "2.0.3"
  s.summary = "A library to use DYI on Rails"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<dyi>, [">= 1.0.0"])
      s.add_development_dependency(%q<rails>, [">= 2.0.0"])
      s.add_runtime_dependency(%q<dyi>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<rails>, [">= 2.0.0"])
    else
      s.add_dependency(%q<dyi>, [">= 1.0.0"])
      s.add_dependency(%q<rails>, [">= 2.0.0"])
      s.add_dependency(%q<dyi>, [">= 1.0.0"])
      s.add_dependency(%q<rails>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<dyi>, [">= 1.0.0"])
    s.add_dependency(%q<rails>, [">= 2.0.0"])
    s.add_dependency(%q<dyi>, [">= 1.0.0"])
    s.add_dependency(%q<rails>, [">= 2.0.0"])
  end
end

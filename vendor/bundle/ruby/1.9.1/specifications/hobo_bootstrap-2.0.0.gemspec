# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hobo_bootstrap"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ignacio Huerta"]
  s.date = "2013-02-27"
  s.description = "A bootstrap based theme for Hobo"
  s.email = "ignacio@ihuerta.net"
  s.homepage = "https://github.com/Hobo/hobo_bootstrap"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "vendor", "taglibs"]
  s.rubyforge_project = "hobo"
  s.rubygems_version = "2.0.3"
  s.summary = "A bootstrap based theme for Hobo"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hobo>, ["~> 2.0.0.pre6"])
      s.add_runtime_dependency(%q<hobo_jquery>, ["~> 2.0.0.pre6"])
      s.add_runtime_dependency(%q<bootstrap-sass>, ["~> 2.1"])
      s.add_runtime_dependency(%q<will_paginate-bootstrap>, ["~> 0.2.1"])
    else
      s.add_dependency(%q<hobo>, ["~> 2.0.0.pre6"])
      s.add_dependency(%q<hobo_jquery>, ["~> 2.0.0.pre6"])
      s.add_dependency(%q<bootstrap-sass>, ["~> 2.1"])
      s.add_dependency(%q<will_paginate-bootstrap>, ["~> 0.2.1"])
    end
  else
    s.add_dependency(%q<hobo>, ["~> 2.0.0.pre6"])
    s.add_dependency(%q<hobo_jquery>, ["~> 2.0.0.pre6"])
    s.add_dependency(%q<bootstrap-sass>, ["~> 2.1"])
    s.add_dependency(%q<will_paginate-bootstrap>, ["~> 0.2.1"])
  end
end

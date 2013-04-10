# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "hobo_support"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Locke"]
  s.date = "2013-02-27"
  s.description = "Core Ruby extensions from the Hobo project"
  s.email = "tom@tomlocke.com"
  s.homepage = "http://hobocentral.net"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "hobo"
  s.rubygems_version = "2.0.3"
  s.summary = "Core Ruby extensions from the Hobo project"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.2.0"])
      s.add_development_dependency(%q<rubydoctest>, [">= 0"])
    else
      s.add_dependency(%q<rails>, ["~> 3.2.0"])
      s.add_dependency(%q<rubydoctest>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.2.0"])
    s.add_dependency(%q<rubydoctest>, [">= 0"])
  end
end

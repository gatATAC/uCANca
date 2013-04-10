# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "jquery-ui-themes"
  s.version = "0.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Asson"]
  s.date = "2012-11-27"
  s.description = "Allow inclusion of the pre built jquery themes in the asset pipeline without having to edit the files each time."
  s.email = ["mark@fatdude.net"]
  s.homepage = "https://github.com/fatdude/jquery-ui-themes-rails"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Simple integration of jquery themes into the asset pipeline"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
  end
end

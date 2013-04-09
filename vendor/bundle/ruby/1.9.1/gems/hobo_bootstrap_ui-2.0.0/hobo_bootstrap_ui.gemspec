name = File.basename( __FILE__, '.gemspec' )
version = File.read(File.expand_path('../VERSION', __FILE__)).strip
require 'date'

Gem::Specification.new do |s|

  s.authors = ['Ignacio Huerta']
  s.email = 'ignacio@ihuerta.net'
  s.homepage = 'https://github.com/Hobo/hobo_bootstrap_ui'
  s.rubyforge_project = 'hobo'
  s.summary = 'Additional UI tags for the hobo_bootstrap theme'
  s.description = 'Additional UI tags for the hobo_bootstrap theme'

  s.add_runtime_dependency('hobo_bootstrap', "~> 2.0.0.pre1")
  s.add_runtime_dependency('bootstrap-datepicker-rails')

  s.files = `git ls-files -x #{name}/* -z`.split("\0")

  s.name = name
  s.version = version
  s.date = Date.today.to_s

  s.required_rubygems_version = ">= 1.3.6"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "taglibs"]

end

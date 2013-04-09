# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fastthread"
  s.version = "1.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["MenTaLguY <mental@rydia.net>"]
  s.date = "2009-04-08"
  s.description = "Optimized replacement for thread.rb primitives"
  s.email = "mental@rydia.net"
  s.extensions = ["ext/fastthread/extconf.rb"]
  s.extra_rdoc_files = ["ext/fastthread/fastthread.c", "ext/fastthread/extconf.rb", "CHANGELOG"]
  s.files = ["ext/fastthread/fastthread.c", "ext/fastthread/extconf.rb", "CHANGELOG"]
  s.homepage = ""
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Fastthread"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = "mongrel"
  s.rubygems_version = "2.0.3"
  s.summary = "Optimized replacement for thread.rb primitives"
end

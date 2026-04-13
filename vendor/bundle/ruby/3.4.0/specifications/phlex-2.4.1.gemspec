# -*- encoding: utf-8 -*-
# stub: phlex 2.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "phlex".freeze
  s.version = "2.4.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/phlex-ruby/phlex/releases", "funding_uri" => "https://github.com/sponsors/joeldrapper", "homepage_uri" => "https://www.phlex.fun", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/phlex-ruby/phlex" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joel Drapper".freeze, "Will Cosgrove".freeze]
  s.date = "2026-02-06"
  s.description = "Build HTML, SVG and CSV views with Ruby classes.".freeze
  s.email = ["joel@drapper.me".freeze]
  s.homepage = "https://www.phlex.fun".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "3.5.3".freeze
  s.summary = "Object-oriented views in Ruby.".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.7".freeze])
  s.add_runtime_dependency(%q<refract>.freeze, ["~> 1.0".freeze])
end

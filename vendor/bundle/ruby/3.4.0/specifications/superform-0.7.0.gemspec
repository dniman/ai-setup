# -*- encoding: utf-8 -*-
# stub: superform 0.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "superform".freeze
  s.version = "0.7.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/rubymonolith/superform", "homepage_uri" => "https://github.com/rubymonolith/superform", "source_code_uri" => "https://github.com/rubymonolith/superform" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Brad Gessler".freeze]
  s.bindir = "exe".freeze
  s.date = "2026-03-02"
  s.description = "A better way to customize and build forms for your Rails application".freeze
  s.email = ["bradgessler@gmail.com".freeze]
  s.homepage = "https://github.com/rubymonolith/superform".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.6.2".freeze
  s.summary = "Build forms in Rails".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<phlex-rails>.freeze, ["~> 2.0".freeze])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.6".freeze])
end

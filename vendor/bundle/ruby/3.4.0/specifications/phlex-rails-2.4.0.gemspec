# -*- encoding: utf-8 -*-
# stub: phlex-rails 2.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "phlex-rails".freeze
  s.version = "2.4.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/phlex-ruby/phlex-rails/releases", "funding_uri" => "https://github.com/sponsors/joeldrapper", "homepage_uri" => "https://www.phlex.fun", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/phlex-ruby/phlex-rails" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joel Drapper".freeze, "Will Cosgrove".freeze]
  s.date = "1980-01-02"
  s.description = "Object-oriented views in pure Ruby.".freeze
  s.email = ["joel@drapper.me".freeze]
  s.homepage = "https://www.phlex.fun".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.2".freeze)
  s.rubygems_version = "4.0.3".freeze
  s.summary = "A Phlex adapter for Rails".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<phlex>.freeze, ["~> 2.4.0".freeze])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 7.1".freeze, "< 9".freeze])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.7".freeze])
end

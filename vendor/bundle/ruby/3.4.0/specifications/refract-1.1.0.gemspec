# -*- encoding: utf-8 -*-
# stub: refract 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "refract".freeze
  s.version = "1.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "funding_uri" => "https://github.com/sponsors/joeldrapper", "homepage_uri" => "https://github.com/yippee-fun/refract", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/yippee-fun/refract" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joel Drapper".freeze]
  s.date = "1980-01-02"
  s.description = "Ruby code rewriter.".freeze
  s.email = ["joel@drapper.me".freeze]
  s.homepage = "https://github.com/yippee-fun/refract".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "3.6.7".freeze
  s.summary = "Ruby code rewriter.".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<prism>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, [">= 0".freeze])
end

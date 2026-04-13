# -*- encoding: utf-8 -*-
# stub: ancestry 5.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ancestry".freeze
  s.version = "5.1.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/stefankroes/ancestry/issues", "changelog_uri" => "https://github.com/stefankroes/ancestry/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/stefankroes/ancestry", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/stefankroes/ancestry/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Stefan Kroes".freeze, "Keenan Brock".freeze]
  s.date = "1980-01-02"
  s.description = "  Ancestry allows the records of a ActiveRecord model to be organized in a tree\n  structure, using the materialized path pattern. It exposes the standard\n  relations (ancestors, parent, root, children, siblings, descendants)\n  and allows them to be fetched in a single query. Additional features include\n  named scopes, integrity checking, integrity restoration, arrangement\n  of (sub)tree into hashes and different strategies for dealing with orphaned\n  records.\n".freeze
  s.email = "keenan@thebrocks.net".freeze
  s.homepage = "https://github.com/stefankroes/ancestry".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "Thank you for installing Ancestry. You can visit http://github.com/stefankroes/ancestry to read the documentation.".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "4.0.6".freeze
  s.summary = "Organize ActiveRecord model into a tree structure".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 5.2.6".freeze])
  s.add_runtime_dependency(%q<logger>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<appraisal>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<minitest>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<yard>.freeze, [">= 0".freeze])
end

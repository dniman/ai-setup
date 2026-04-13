# -*- encoding: utf-8 -*-
# stub: acts_as_list 1.2.6 ruby lib

Gem::Specification.new do |s|
  s.name = "acts_as_list".freeze
  s.version = "1.2.6".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/brendon/acts_as_list/issues", "changelog_uri" => "https://github.com/brendon/acts_as_list/blob/master/CHANGELOG.md", "funding_uri" => "https://github.com/sponsors/brendon", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/brendon/acts_as_list" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Swanand Pagnis".freeze, "Brendon Muir".freeze]
  s.date = "2025-10-21"
  s.description = "This \"acts_as\" extension provides the capabilities for sorting and reordering a number of objects in a list. The class that has this specified needs to have a \"position\" column defined as an integer on the mapped database table.".freeze
  s.email = ["swanand.pagnis@gmail.com".freeze, "brendon@spikeatschool.co.nz".freeze]
  s.homepage = "https://github.com/brendon/acts_as_list".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.5.22".freeze
  s.summary = "A gem adding sorting, reordering capabilities to an active_record model, allowing it to act as a list".freeze

  s.installed_by_version = "3.6.9".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.1".freeze])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 6.1".freeze])
end

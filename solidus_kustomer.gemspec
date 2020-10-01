# frozen_string_literal: true

require_relative 'lib/solidus_kustomer/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_kustomer'
  spec.version = SolidusKustomer::VERSION
  spec.authors = ['Nicolò Rebughini']
  spec.email = 'nicolo.rebughini@gmail.com'

  spec.summary = 'Kustomer integration for Solidus stores'
  spec.description = 'Kustomer integration for Solidus stores'
  spec.homepage = 'https://github.com/nebulab/nirebu/solidus_kustomer'
  spec.license = 'BSD-3-Clause'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/[USERNAME]/solidus_kustomer'
  spec.metadata['changelog_uri'] = 'https://github.com/[USERNAME]/solidus_kustomer/releases'

  spec.required_ruby_version = Gem::Requirement.new('~> 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'solidus_core', ['>= 2.0.0', '< 3']
  spec.add_dependency 'solidus_support', '~> 0.5'

  spec.add_dependency 'httparty', '~> 0.18'
  spec.add_dependency 'solidus_tracking', '~> 0.0'

  spec.add_development_dependency 'solidus_dev_support', '~> 2.0'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end

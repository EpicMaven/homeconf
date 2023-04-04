# frozen_string_literal: true

require_relative 'lib/homeconf/version'

Gem::Specification.new do |s|
  s.name = 'homeconf'
  s.version = Homeconf::VERSION
  s.authors = ['Mark Lundquist']
  s.email = ['homeconf@epicmaven.com']
  s.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  s.summary = 'Homeconf manages portable, version controlled home directory configuration.'
  s.description = <<-DESCRIPTION
    Homeconf is a Ruby program to create and manage a single directory for all home directory configuration.
  DESCRIPTION
  s.homepage = 'https://github.com/EpicMaven/homeconf'
  s.license = 'Apache-2.0'

  if s.respond_to? :metadata=
    s.metadata = {
      'homepage_uri' => s.homepage,
      'bug_tracker_uri' => "#{s.homepage}/issues",
      'source_code_uri' => "#{s.homepage}/tree/v#{s.version}",
      'documentation_uri' => "https://rubydoc.info/gems/EpicMaven/#{s.version}"
    }
  end

  s.files = %w[LICENSE NOTICE README.md]
  s.files += Dir.glob('{bin,lib}/**/*', File::FNM_DOTMATCH)
  s.bindir = 'bin'
  s.executables = ['homeconf']
  s.require_path = ['lib']
  s.rdoc_options = %w[--main README.md --title=homeconf]
  s.extra_rdoc_files = %w[HEADER LICENSE NOTICE README.md]

  s.add_development_dependency 'faker', '~> 3.1.1', '>= 3.0.0'
  s.add_development_dependency 'parser', '~> 3.2.1', '>= 3.2.0'
  s.add_development_dependency 'rspec', '~> 3.12', '>= 3.0.0'
  s.add_development_dependency 'rspec-parameterized', '~> 1.0.0', '>= 1.0.0'

  s.specification_version = 4
end

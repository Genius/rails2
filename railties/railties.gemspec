require File.expand_path('../../railslts-version/lib/railslts-version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'railties'
  s.version = RailsLts::VERSION::STRING
  s.summary = 'Tools for creating, working with, and running Rails applications.'
  s.description = 'Rails internals: application bootup, plugins, generators, and rake tasks.'

  s.author = 'David Heinemeier Hansson'
  s.email = 'david@loudthinking.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.require_path = 'lib'
  s.files = ['bin/rails']
  s.executables = ['rails']
  s.rdoc_options = ['--exclude', '.']

  s.add_dependency 'rake',           '>= 0.8.3'
  s.add_dependency 'activesupport',  "= #{RailsLts::VERSION::STRING}"
  s.add_dependency 'actionpack',     "= #{RailsLts::VERSION::STRING}"
end

require File.expand_path('../../railties/lib/railslts/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'actionpack'
  s.version = RailsLts::VERSION::STRING
  s.summary = 'Web-flow and rendering framework putting the VC in MVC.'
  s.description = 'Eases web-request routing, handling, and response as a half-way front, half-way page controller. Implemented with specific emphasis on enabling easy unit/integration testing that doesn\'t require a browser.'

  s.author = 'David Heinemeier Hansson'
  s.email = 'david@loudthinking.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.require_path = 'lib'

  s.add_dependency 'activesupport', "= #{RailsLts::VERSION::STRING}"
  s.add_dependency 'rack', '< 1.5'
end

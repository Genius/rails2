require File.expand_path('../../railties/lib/railslts/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'actionmailer'
  s.version = RailsLts::VERSION::STRING
  s.summary = 'Service layer for easy email delivery and testing.'
  s.description = 'Makes it trivial to test and deliver emails sent from a single service layer.'

  s.author = 'David Heinemeier Hansson'
  s.email = 'david@loudthinking.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.require_path = 'lib'

  s.add_dependency 'actionpack', "= #{RailsLts::VERSION::STRING}"
end

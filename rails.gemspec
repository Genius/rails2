require File.expand_path('../railties/lib/railslts/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'rails'
  s.version = RailsLts::VERSION::STRING
  s.summary = 'Full-stack web application framework.'
  s.description = 'Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.'

  s.author = 'David Heinemeier Hansson'
  s.email = 'david@loudthinking.com'
  s.homepage = 'http://www.rubyonrails.org'

  s.files = [ "README.md", "LICENSE" ]

  s.add_dependency 'activesupport',    "= #{RailsLts::VERSION::STRING}"
  s.add_dependency 'activerecord',     "= #{RailsLts::VERSION::STRING}"
  s.add_dependency 'actionpack',       "= #{RailsLts::VERSION::STRING}"
  s.add_dependency 'actionmailer',     "= #{RailsLts::VERSION::STRING}"
  s.add_dependency 'activeresource',   "= #{RailsLts::VERSION::STRING}"
  s.add_dependency 'railties',         "= #{RailsLts::VERSION::STRING}"
  # we do not depend on railslts-version anymore; the dependency has been reversed
end

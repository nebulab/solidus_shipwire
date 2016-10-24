# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_shipwire'
  s.version     = '1.0.0'
  s.summary     = 'Solidus shipwire integration'
  s.description = 'Solidus shipwire integration'
  s.required_ruby_version = '>= 1.8.7'

  s.author    = 'Daniele Palombo'
  s.email     = 'danielepalombo@nebulab.it'
  s.homepage  = 'http://github.com/nebulab/solidus_shipwire'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency %q<solidus_core>, ["< 3", ">= 1.0.6"]
  s.add_dependency %q<solidus_backend>, ["< 3", ">= 1.0.6"]
  s.add_dependency %q<shipwire>, '~> 2.0'

  s.add_development_dependency 'capybara', '1.0.1'
  s.add_development_dependency 'factory_girl', '~> 2.6.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.9'
  s.add_development_dependency 'sqlite3'
end

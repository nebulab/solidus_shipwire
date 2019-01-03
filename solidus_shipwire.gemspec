# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_shipwire'
  s.version     = '1.0.0'
  s.summary     = 'Solidus shipwire integration'
  s.description = 'This extension provide the ability to connect in a easy '+
                  'way your store and shipwire through API and Webhooks'
  s.required_ruby_version = '>= 1.8.7'

  s.author   = 'Daniele Palombo'
  s.email    = 'danielepalombo@nebulab.it'
  s.homepage = 'http://github.com/solidusio-contrib/solidus_shipwire'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'active_model_serializers', '>= 0.10.0'

  s.add_runtime_dependency 'solidus_core',    ['>= 1.0', '< 3']
  s.add_runtime_dependency 'solidus_backend', ['>= 1.0', '< 3']
  s.add_runtime_dependency 'shipwire', '~> 2.0'

  s.add_runtime_dependency 'activerecord', ['>= 4.0']
  s.add_runtime_dependency 'solidus_support'
  s.add_runtime_dependency 'retriable'

  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'vcr', '~> 3.0'
  s.add_development_dependency 'webmock', '~> 2.1'
  s.add_development_dependency 'sqlite3'
end

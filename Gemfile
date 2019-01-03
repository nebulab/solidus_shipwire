source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem 'solidus', github: 'solidusio/solidus', branch: branch

group :test do
  if branch == 'master' || branch >= 'v2.0'
    gem 'rails-controller-testing'
  else
    gem 'rails_test_params_backport'
  end
  if branch < "v2.5"
    gem 'factory_bot', '4.10.0'
  else
    gem 'factory_bot', '> 4.10.0'
  end
end

group :development, :test do
  gem "pry-rails"
  gem 'i18n-tasks', '~> 0.9' if branch == 'master'
end

gem 'simplecov', require: false, group: :test

gem 'mysql2'
gem 'sqlite3'
gem 'pg'

gem 'shipwire', github: 'nebulab/shipwire'

gemspec

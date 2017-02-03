require 'rubygems'
require 'bundler/setup'

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'spree/testing_support/common_rake'

RSpec::Core::RakeTask.new

task :default do
  if ENV['APPRAISAL_INITIALIZED'].present?
    Rake::Task[:appraisal].invoke if !ENV['APPRAISAL_INITIALIZED'] && !ENV['TRAVIS']
  end

  Rake::Task[:test_app].invoke
  Dir.chdir('../../')

  Rake::Task[:spec].invoke
end

desc 'Generates a dummy app for testing'
task :test_app do
  ENV['LIB_NAME'] = 'solidus_shipwire'
  Rake::Task['common:test_app'].invoke
end

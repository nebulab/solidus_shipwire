require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/support/cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.filter_sensitive_data('<Authorization Code>') do |interaction|
    interaction.request.headers['Authorization'].first
  end
  config.configure_rspec_metadata!
end

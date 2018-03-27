module SolidusShipwire
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'solidus_shipwire'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'solidus_shipwire.environment', before: 'spree.environment' do
      Spree::ShipwireConfig = Spree::ShipwireConfiguration.new
    end

    initializer 'solidus_shipwire.environment', after: 'finisher_hook' do
      Spree::ShipwireConfig.setup_shipwire
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      require 'solidus_shipwire/shipwire_objects/order'
      #require 'solidus_shipwire/shipwire_objects/return_authorization'
    end

    config.to_prepare &method(:activate).to_proc
  end
end

module Spree
  class SolidusShipwireConfiguration < Preferences::Configuration
    preference :username,     :string,  default: nil
    preference :password,     :string,  default: nil
    preference :open_timeout, :integer, default: 2
    preference :timeout,      :integer, default: 5
    preference :endpoint,     :string,  default: 'http://api.shipwire.com'
    preference :logger,       :string,  default: false
    preference :secret,       :string,  default: nil

    def set_shipwire
      Shipwire.configure do |config|
        config.username     = username
        config.password     = password
        config.open_timeout = open_timeout
        config.timeout      = timeout
        config.endpoint     = endpoint
        config.logger       = logger
      end
    end
  end
end

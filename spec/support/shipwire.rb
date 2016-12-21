solidus_shipwire_config = Spree::ShipwireConfiguration.new
solidus_shipwire_config.username = 'email@email.com'
solidus_shipwire_config.password = 'password'
solidus_shipwire_config.endpoint = 'https://api.beta.shipwire.com'
solidus_shipwire_config.secret   = 'mysecret'

solidus_shipwire_config.setup_shipwire

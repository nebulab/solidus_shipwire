require 'solidus_core'
require 'solidus_backend'
require 'solidus_support'
require 'active_record'

require 'shipwire'
require 'active_model_serializers'

require 'solidus_shipwire/engine'
require 'solidus_shipwire/response_decorator'
require 'solidus_shipwire/response_exception'
require 'solidus_shipwire/shipwireable'

ActiveSupport.on_load(:active_record) do
  extend SolidusShipwire::Shipwireable
end

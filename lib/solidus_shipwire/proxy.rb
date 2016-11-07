module SolidusShipwire
  module Proxy
    def self.prepended(_base)
      klass = Class.new SolidusShipwire::ShipwireObject
      _base.const_set 'ShipwireObject', klass
    end

    def in_shipwire
      @object ||= find_or_create_on_shipwire_api(shipwire_id)
    end

    def find_or_create_on_shipwire_api(shipwire_id)
      shipwire_response = find_on_shipwire(shipwire_id)

      unless shipwire_response.ok?
        shipwire_response = create_on_shipwire(to_shipwire)
      end

      to_shipwire_object(shipwire_response.body['resource'])
    end
  end
end

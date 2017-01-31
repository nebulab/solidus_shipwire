module SolidusShipwire
  module Proxy
    def self.prepended(base)
      klass = Class.new SolidusShipwire::ShipwireObject
      base.const_set 'ShipwireObject', klass
    end

    def in_shipwire
      find_or_create_on_shipwire_api(shipwire_id)
    end

    def find_or_create_on_shipwire_api(shipwire_id)
      shipwire_response = find_on_shipwire(shipwire_id)

      unless shipwire_response.ok?
        shipwire_response = create_on_shipwire(to_shipwire)
      end

      to_shipwire_object(shipwire_response.body['resource'])
    end

    def find_on_shipwire(shipwire_id)
      shipwire_instance.find shipwire_id
    end

    def update_on_shipwire
      shipwire_instance.update(shipwire_id, to_shipwire)
    end

    def shipwire_instance
      super
    rescue NoMethodError
      raise 'override shipwire_instance'
    end

    def create_on_shipwire(obj)
      response = shipwire_instance.create(obj)
      raise SolidusShipwire::ResponseException.new(response), response.error_report unless response.ok?
      update_column(:shipwire_id, response.body['resource']['items'].first['resource']['id'])
      find_on_shipwire(response.body['resource']['items'].first['resource']['id'])
    end
  end
end

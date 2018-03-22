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
        shipwire_response = create_on_shipwire
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
    rescue NameError
      raise NameError, 'override shipwire_instance'
    end

    def to_shipwire_object(params)
      super
    rescue NameError
      raise NameError, 'override to_shipwire_object'
    end

    def create_on_shipwire
      response = shipwire_instance.create(to_shipwire)
      raise SolidusShipwire::ResponseException.new(response), response.error_report unless response.ok?
      shipwire_id = response.body['resource']['items'].first['resource']['id']
      update_shipwire_id(shipwire_id)
      find_on_shipwire(shipwire_id)
    end

    def update_shipwire_id(shipwire_id)
      if persisted?
        update_column(:shipwire_id, shipwire_id)
      else
        self.shipwire_id = shipwire_id
      end
    end
  end
end

module ShipwireFactory
  class Warehouse
    def default
      Shipwire::Warehouses.new.list(type: 'SHIPWIRE_ANYWHERE').body['resource']['items'].first['resource']
    rescue NoMethodError
      raise 'No warehouse of type SHIPWIRE_ANYWHERE on shipwire'
    end
  end
end

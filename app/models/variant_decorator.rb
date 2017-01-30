module SolidusShipwire
  module Variant
    prepend SolidusShipwire::Proxy

    def update_stocks_from_shipwire
      Shipwire::Stock.new.list( sku: self.sku)
    end

    def to_shipwire
      {
        sku: sku,
        classification: "baseProduct",
        description: name,
        countryOfOrigin: "US",
        category: "FURNITURE_&_APPLIANCES",
        batteryConfiguration: 'NOBATTERY',
        values: {
          costValue: self.price,
        #  wholesaleValue: 2,
          retailValue: self.price,
          costCurrency: "USD",
        #  wholesaleCurrency: "USD",
          retailCurrency: "USD"
        },
        dimensions: {
          length: 1,
          width: 10,
          height: 1,
          weight: 1
        }
      }
    end

    def create_on_shipwire(obj)
      response = Shipwire::Products.new.create(obj)
      raise SolidusShipwire::ResponseException.new(response), response.error_report unless response.ok?
      self.update_column(:shipwire_id, response.body['resource']['items'].first['resource']['id'])
      find_on_shipwire(response.body['resource']['items'].first['resource']['id'])
    end

    def find_on_shipwire shipwire_id
      Shipwire::Products.new.find shipwire_id
    end

    def to_shipwire_object(hash)
      ShipwireObject.new(hash["id"], self, hash)
    end
  end
end

Spree::Variant.prepend SolidusShipwire::Variant

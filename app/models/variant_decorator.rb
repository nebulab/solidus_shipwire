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

    def to_shipwire_object(hash)
      ShipwireObject.new(hash["id"], self, hash)
    end

    private

    def shipwire_instance
      Shipwire::Products.new
    end
  end
end

Spree::Variant.prepend SolidusShipwire::Variant

module SolidusShipwire
  module VariantDecorator
    def self.prepended(base)
      base.acts_as_shipwireable api_class: Shipwire::Products
    end

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
    Spree::Variant.prepend self
  end
end

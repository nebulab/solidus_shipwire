module SolidusShipwire
  class VariantSerializer < ActiveModel::Serializer
    attributes :sku, :values, :dimensions

    attribute :name, key: :description

    attribute(:classification) { "baseProduct" }
    attribute(:countryOfOrigin) { "US" }
    attribute(:category) { "FURNITURE_&_APPLIANCES" }
    attribute(:batteryConfiguration) { "NOBATTERY" }

    def values
      {
        costValue: object.price,
        retailValue: object.price,
        costCurrency: "USD",
        retailCurrency: "USD"
      }
    end

    def dimensions
      {
        length: 1,
        width: 10,
        height: 1,
        weight: 1
      }
    end
  end
end

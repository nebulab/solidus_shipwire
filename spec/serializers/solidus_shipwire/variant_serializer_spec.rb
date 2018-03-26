require 'spec_helper'

describe SolidusShipwire::VariantSerializer do
  context "#as_json" do
    let!(:variant) { create(:variant) }

    subject { SolidusShipwire::VariantSerializer.new(variant).as_json(include: '**') }

    it "is formatted as shipwire json" do
      is_expected.to include(
        sku: variant.sku,
        classification: "baseProduct",
        description: variant.name,
        countryOfOrigin: "US",
        category: "FURNITURE_&_APPLIANCES",
        batteryConfiguration: 'NOBATTERY',
        values: {
          costValue: variant.price,
          retailValue: variant.price,
          costCurrency: "USD",
          retailCurrency: "USD"
        },
        dimensions: {
          length: 1,
          width: 10,
          height: 1,
          weight: 1
        }
      )
    end
  end
end

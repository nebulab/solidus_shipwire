require 'spec_helper'

describe SolidusShipwire::ShippingManifest::ManifestItemSerializer do
  context "#as_json" do
    let(:shipment)      { create(:shipment, order: order) }
    let(:variant)       { create(:variant, shipwire_id: '1234567') }
    let(:manifest_item) { Spree::ShippingManifest.new(inventory_units: shipment.inventory_units).items.first }

    let(:order) do
      create(:completed_order_with_totals,
             line_items_attributes: [
               variant: variant,
               quantity: 1,
               price: 20
             ])
    end

    subject { described_class.new(manifest_item).as_json(include: '**') }

    it "is formatted as shipwire json" do
      is_expected.to include(
        sku: variant.sku,
        quantity: 1,
        commercialInvoiceValue: 20,
        commercialInvoiceValueCurrency: 'USD'
      )
    end
  end
end

require 'spec_helper'

describe SolidusShipwire::ReturnAuthorizationSerializer do
  context "#as_json" do
    let(:variant)              { create(:variant, shipwire_id: 7_654_321) }
    let(:order)                { create(:shipped_order, line_items_attributes: [variant: variant, quantity: 1]) }
    let(:return_authorization) { create(:return_authorization, order: order) }
    let(:shipment)             { order.shipments.first }
    let(:shipwire_id)          { 1_234_567 }

    before do
      return_authorization.inventory_units << order.inventory_units
      shipment.update_attributes(shipwire_id: shipwire_id)
    end

    subject { described_class.new(return_authorization).as_json(include: '**') }

    it "is formatted as shipwire json" do
      is_expected.to include(
        originalOrder: {
          id: shipwire_id
        },
        items: [
          sku: variant.sku,
          quantity: 1
        ],
        options: {
          generatePrepaidLabel: 0,
          emailCustomer: 0,
        }
      )
    end
  end
end

require 'spec_helper'

describe SolidusShipwire::ShipmentSerializer do
  context "#as_json" do
    let!(:shipment)    { create(:shipment, order: order) }
    let(:variant)      { create(:variant, shipwire_id: '1234567') }
    let(:ship_address) { order.ship_address }

    let(:order) do
      create(:completed_order_with_totals,
             line_items_attributes: [
               variant: variant,
               quantity: 1
             ])
    end

    let(:items_json_node) do
      Spree::ShippingManifest
        .new(inventory_units: shipment.inventory_units.eligible_for_shipwire)
        .items.map(&:to_shipwire_json)
    end

    let(:ship_to_json_node) do
      ship_address.to_shipwire_json.merge(email: order.email)
    end

    subject { SolidusShipwire::ShipmentSerializer.new(shipment).as_json(include: '**') }

    it "is formatted as shipwire json" do
      is_expected.to include(
        orderId: shipment.id,
        orderNo: shipment.number,
        options: {
          warehouseId: shipment.warehouse_id,
          currency:    "USD",
          canSplit:    shipment.shipwire_can_split?,
          hold:        0,
          server:      "Production"
        },
        items:  items_json_node,
        shipTo: ship_to_json_node
      )
    end

    context "no variants synced on shipwire" do
      let(:variant) { create(:variant) }

      it "items is empty" do
        is_expected.to include(items: [])
      end
    end
  end
end

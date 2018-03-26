module SolidusShipwire
  module ShipmentDecorator
    def self.prepended(base)
      base.acts_as_shipwireable api_class: Shipwire::Orders
    end

    def to_shipwire
      {
        orderId: id,
        orderNo: number,
        processAfterDate: process_after_date,
        options: {
          warehouseId: warehouse_id,
          currency: shipwire_currency,
          canSplit: shipwire_can_split?,
          hold: shipwire_hold?,
          server: shipwire_server
        },
        items: shipping_manifest_to_shipwire,
        shipTo: order.ship_address.to_shipwire.merge(email: order.email)
      }
    end

    def shipwire_inventory_units?
      shipwire_inventory_units.any?
    end

    def shipping_manifest_to_shipwire
      Spree::ShippingManifest.
        new(inventory_units: shipwire_inventory_units).
        items.map(&:to_shipwire)
    end

    def shipwire_can_split?
      1
    end

    def shipwire_hold?
      0
    end

    def shipwire_currency
      'USD'
    end

    def shipwire_server
      'Production'
    end

    def process_after_date
      nil
    end

    private

    def shipwire_inventory_units
      @shipwire_inventory_units = inventory_units.eligible_for_shipwire
    end

    def warehouse_id
      Spree::ShipwireConfig.default_warehouse_id
    end

    Spree::Shipment.prepend self
  end
end

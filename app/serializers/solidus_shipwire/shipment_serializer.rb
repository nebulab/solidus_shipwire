module SolidusShipwire
  class ShipmentSerializer < ActiveModel::Serializer
    attribute :id,                            key: :orderId
    attribute :number,                        key: :orderNo

    attribute(:classification) { "baseProduct" }
    attribute(:countryOfOrigin) { "US" }
    attribute(:category) { "FURNITURE_&_APPLIANCES" }
    attribute(:batteryConfiguration) { "NOBATTERY" }
    attribute(:shipTo) { object.order.ship_address.to_shipwire_json.merge(email: object.order.email) }

    attribute(:options) do
      {
        warehouseId: object.warehouse_id,
        currency: "USD",
        canSplit: object.shipwire_can_split?,
        hold: shipwire_hold?,
        server: "Production"
      }
    end

    attribute(:items) do
      Spree::ShippingManifest
        .new(inventory_units: object.inventory_units.eligible_for_shipwire)
        .items.map(&:to_shipwire_json)
    end

    def shipwire_hold?
      0
    end
  end
end

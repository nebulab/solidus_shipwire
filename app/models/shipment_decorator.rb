module SolidusShipwire
  module ShipmentDecorator
    def self.prepended(base)
      base.acts_as_shipwireable api_class: Shipwire::Orders,
                                serializer: SolidusShipwire::ShipmentSerializer
    end

    def shipwire_can_split?
      1
    end

    def warehouse_id
      Spree::ShipwireConfig.default_warehouse_id
    end

    Spree::Shipment.prepend self
  end
end

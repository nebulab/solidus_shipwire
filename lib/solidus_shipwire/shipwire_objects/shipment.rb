module SolidusShipwire
  module ShipwireObjects
    class Shipment < SolidusShipwire::Order::ShipwireObject
      def status
        @attrs[:status]
      end

      def ship_to
        @attrs[:shipTo]
      end

      def ship_from
        @attrs[:shipFrom]
      end
    end
  end
end

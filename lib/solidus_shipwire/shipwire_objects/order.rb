module SolidusShipwire
  module ShipwireObjects
    class Order < SolidusShipwire::Order::ShipwireObject
      def status
        @attrs[:status]
      end

      def shipTo
        @attrs[:shipTo]
      end

      def shipFrom
        @attrs[:shipFrom]
      end
    end
  end
end

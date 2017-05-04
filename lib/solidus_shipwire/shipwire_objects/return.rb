module SolidusShipwire
  module ShipwireObjects
    class Return < SolidusShipwire::Return::ShipwireObject
      def status
        @attrs[:status]
      end
    end
  end
end

module SolidusShipwire
  module ShipwireObjects
    class ReturnAuthorization < SolidusShipwire::ReturnAuthorization::ShipwireObject
      def status
        @attrs[:status]
      end
    end
  end
end

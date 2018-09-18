module SolidusShipwire
  module Shipwireable
    def shipwireable?
      false
    end

    def acts_as_shipwireable(*args)
      acts_as_shipwireable_on(*args)
    end

    private

    def acts_as_shipwireable_on(config)
      class_attribute :shipwireable_config unless shipwireable?
      self.shipwireable_config = config

      class_eval do
        def self.shipwireable?
          true
        end
      end

      include ShipwireSerializer
      include ShipwireApi
    end
  end
end

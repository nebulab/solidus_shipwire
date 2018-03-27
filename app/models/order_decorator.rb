module SolidusShipwire
  module OrderDecorator
    def self.prepended(base)
      base.after_save :update_shipments_on_shipwire
    end

    def update_shipments_on_shipwire
      return unless complete?

      shipments.each do |shipment|
        shipment.update_on_shipwire if shipment.shipwire_id.present?
      end
    end

    Spree::Order.prepend self
  end
end

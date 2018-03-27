module SolidusShipwire
  class ReturnAuthorizationSerializer < ActiveModel::Serializer
    attribute(:originalOrder) do
      {
        id: shipment.shipwire_id
      }
    end

    attribute(:items) do
      object.return_items.each_with_object(Hash.new(0)) do |item, hash|
        hash[item.variant.sku] += 1
      end.map { |s, q| { sku: s, quantity: q } }
    end

    attribute(:options) do
      {
        generatePrepaidLabel: 0,
        emailCustomer: 0,
      }
    end

    def shipment
      object.return_items.first.shipment
    end
  end
end

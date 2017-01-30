# Fix for retrieve order from Shipwire gem
module SolidusShipwire
  module FixFindOrder
    def find(id, params = {})
      request(:get, "orders/#{id}", params: params)
    end
  end
end

Shipwire::Orders.prepend SolidusShipwire::FixFindOrder

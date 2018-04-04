# Fix for retrieve order from Shipwire gem
module SolidusShipwire
  module OrdersDecorator
    def find(id, params = {})
      request(:get, "orders/#{id}", params: params)
    end

    def holds_clear(id)
      request(:post, "orders/#{id}/holds/clear")
    end

    def mark_processed(id)
      request(:post, "orders/#{id}/markProcessed")
    end

    def mark_submitted(id)
      request(:post, "orders/#{id}/markSubmitted")
    end

    def mark_complete(id)
      request(:post, "orders/#{id}/markComplete")
    end

    Shipwire::Orders.prepend self
  end
end

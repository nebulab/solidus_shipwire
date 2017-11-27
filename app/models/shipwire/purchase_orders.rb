module Shipwire
  class PurchaseOrders < Api
    def list(params = {})
      request(:get, 'purchaseOrders', params: params)
    end

    def create(body)
      request(:post, 'purchaseOrders', body: body)
    end

    def find(id, params = {})
      request(:get, "purchaseOrders/#{id}", params: params)
    end

    def update(id, body, params = {})
      request(:put, "purchaseOrders/#{id}", body: body, params: params)
    end

    def cancel(id)
      request(:post, "purchaseOrders/#{id}/cancel")
    end

    def items(id)
      request(:get, "purchaseOrders/#{id}/items")
    end

    def approve(id)
      request(:post, "purchaseOrders/#{id}/approve")
    end

    def trackings(id)
      request(:get, "purchaseOrders/#{id}/trackings")
    end
  end
end

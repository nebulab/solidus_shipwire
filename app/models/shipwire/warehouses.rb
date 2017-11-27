module Shipwire
  class Warehouses < ApiV31
    def list(params = {})
      request(:get, 'warehouses', params: params)
    end

    def create(body)
      request(:post, 'warehouses', body: body)
    end

    def find(id, params = {})
      request(:get, "warehouses/#{id}", params: params)
    end

    def update(id, body, params = {})
      request(:put, "warehouses/#{id}", body: body, params: params)
    end
  end
end

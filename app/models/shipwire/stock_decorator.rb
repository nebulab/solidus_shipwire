module SolidusShipwire
  module StockDecorator
    def adjust(body = {})
      request(:post, 'stock/adjust', body: body)
    end

    Shipwire::Stock.prepend self
  end
end

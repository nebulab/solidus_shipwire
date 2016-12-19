module ShipwireWebhooks
  class StockController < ShipwireWebhookController
    # stock.transition
    def create
      params[:productId]
      params[:warehouseId]
    end

    def product

    end
  end
end

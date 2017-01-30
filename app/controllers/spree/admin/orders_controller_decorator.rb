module SolidusShipwire
  module ShipwireController
    def self.prepended(base)
      base.before_action :load_shipwire_order, only: [:shipwire, :sync_with_shipwire]
    end

    def shipwire
      order_to_shipwire
    end

    def sync_with_shipwire
      respond_to do |format|
        format.js do
          order_to_shipwire
        end
      end
    end

    private

    def order_to_shipwire
      @shipwire_data = @order.in_shipwire
    rescue ResponseException => e
      @error = e.response
    rescue RuntimeError => e
      @error = e.message
    end

    def load_shipwire_order
      load_order
    end
  end
end

Spree::Admin::OrdersController.prepend SolidusShipwire::ShipwireController

module Spree
  module ShipwireWebhooks
    class StockController < Spree::ShipwireWebhookController
      # stock.transition
      def create
        if body['toState'].inquiry.good?
          stock_item.tap do |si|
            si.stock_movements.create(quantity: delta)
            si.set_count_on_hand stock_quantity
          end
        end

        render json: :ok
      rescue ActiveRecord::RecordNotFound => e
        render json: e.message, status: 404
      rescue StandardError => e
        render json: e.message, status: 500
      end

      private

      def variant
        @variant ||= Spree::Variant.find_by_shipwire_id! body['productId']
      end

      def stock_location
        @stock_location ||= Spree::StockLocation.find_by_shipwire_id! body['warehouseId']
      end

      def stock_item
        @stock_item = variant.stock_items.find_by_stock_location_id!(stock_location)
      end

      def delta
        body['delta']
      end

      def stock_quantity
        body['toStateStockAfterTransition']
      end

      def body
        @body ||= params['body']
      end
    end
  end
end

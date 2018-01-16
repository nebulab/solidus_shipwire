module Spree
  module Shipwire
    class RateController < StoreController
      respond_to :json

      def create
        rates = shipwire_rate(rate_params)

        if rates.empty?
          render json: { error: 'Rate not found' }, status: :not_found
        elsif rates.map{ |r| r['serviceOptions'].any? }.none?
          render json: { error: 'Service not found' }, status: :not_found
        else
          render json: { rates: rates }
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      private

      def shipwire_rate(rate_params)
        rate = ::Shipwire::Rate.new.find(rate_params)
        raise rate.error_report unless rate.ok?
        rate.body['resource']['rates']
      end

      def rate_params
        {
          order: {
            shipTo: order_shipwire_json[:shipTo],
            items: order_shipwire_json[:items]
          },
          options: {
            currency: order_shipwire_json[:options][:currency],
            canSplit: order_shipwire_json[:options][:canSplit],
            expectedShipDate: expected_ship_date
          }
        }
      end

      def expected_ship_date
        ship_date = params[:expectedShipDate] || nil
        return if ship_date.nil?

        process_after_date = DateTime.strptime(ship_date).to_datetime.to_s
        process_after_date if process_after_date > DateTime.current
      end

      def order
        @order ||= current_order || Order.incomplete.find_by(guest_token: params[:order_guest_token])
      end

      def order_shipwire_json
        @order_shipwire_json ||= order.to_shipwire
      end
    end
  end
end

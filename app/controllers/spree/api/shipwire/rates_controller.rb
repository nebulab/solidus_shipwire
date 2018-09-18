module Spree
  module Api
    module Shipwire
      class RatesController < StoreController
        respond_to :json

        def index
          rates = shipwire_rates(shipment_params)

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

        def shipwire_rates(shipment_params)
          rates = ::Shipwire::Rate.new.find(shipment_params)
          raise rates.error_report unless rates.ok?
          rates.body['resource']['rates']
        end

        def shipment_params
          {
            order: {
              shipTo: shipment_shipwire_json[:shipTo],
              items: shipment_shipwire_json[:items]
            },
            options: {
              currency: shipment_shipwire_json[:options][:currency],
              canSplit: shipment_shipwire_json[:options][:canSplit],
              expectedShipDate: expected_ship_date
            }
          }
        end

        def expected_ship_date
          ship_date = params[:expectedShipDate] || nil
          return if ship_date.nil?

          process_after_date = Time.strptime(ship_date, '%Y-%m-%dT%H:%M:%S%z').iso8601
          process_after_date if process_after_date > Time.zone.now
        end

        def shipment
          @shipment ||= order.shipments.find_by number: params[:shipment_id]
        end

        def order
          @order ||= current_order || Order.incomplete.find_by(guest_token: params[:order_guest_token])
        end

        def shipment_shipwire_json
          @shipment_shipwire_json ||= shipment.to_shipwire_json
        end
      end
    end
  end
end

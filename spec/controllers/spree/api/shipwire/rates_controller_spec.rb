RSpec.describe Spree::Api::Shipwire::RatesController, type: :controller do
  controller Spree::Api::Shipwire::RatesController do
  end

  let(:shipwire_product) { sw_product_factory.in_stock }
  let(:product)          { create(:product, sku: shipwire_product['sku']) }
  let(:order)            { create(:order_with_line_items, line_items_attributes: [product: variant.product] ) }
  let(:shipment)         { order.shipments.first }

  let(:variant) do
    product.master.tap { |master| master.update_attributes(shipwire_id: shipwire_product['id']) }
  end

  let(:rate_params) { { shipment_id: shipment.number, order_guest_token: order.guest_token } }

  subject { get :index, params: rate_params }

  context 'when receive rate information', vcr: { cassette_name: 'shipwire/extract_rate' } do
    let(:json_response) { JSON.parse(response.body) }
    let(:service_options) { json_response['rates'].first }

    it 'return service options info' do
      subject

      expect(json_response).to include 'rates'

      expect(json_response['rates'].count).to eq 1
      json_response['rates'].each do |service_options|
        expect(service_options['serviceOptions'].count).to eq 3

        service_options['serviceOptions'].each do |service_option|
          expect(service_option).to include 'serviceLevelCode',
                                            'serviceLevelName'

          shipment = service_option['shipments'].first

          expect(shipment).to include 'expectedDeliveryMaxDate',
                                      'expectedDeliveryMinDate',
                                      'expectedShipDate',
                                      'warehouseName',
                                      'carrier',
                                      'cost'
        end
      end
    end

    context 'stub the rate api' do
      before do
        allow(Shipwire::Rate).to receive(:new).and_return shipwire_api
        subject
      end

      context 'expected ship date' do
        RSpec::Matchers.define :expected_ship_date do |expected_ship_date|
          match { |hash| hash[:options][:expectedShipDate] == expected_ship_date }
        end

        let(:shipwire_api) { double('ShipwireApi', find: true) }

        it 'is nil' do
          expect(shipwire_api).to have_received(:find).with(expected_ship_date(nil))
        end

        context 'is in the future' do
          let(:expectedShipDate) { (Time.zone.now + 2.weeks).iso8601 }
          let(:rate_params) do
            {
              shipment_id: order.shipments.first.number,
              order_guest_token: order.guest_token,
              expectedShipDate: expectedShipDate
            }
          end

          it 'expectedShipDate is setted' do
            expect(shipwire_api).to have_received(:find).with(expected_ship_date(expectedShipDate))
          end
        end
      end

      context 'with empty services' do
        context 'no service available' do
          let(:shipwire_rate) do
            {
              resource: {
                rates: [{ 'serviceOptions': [] }]
              }
            }.deep_stringify_keys
          end

          let(:shipwire_response) { double('ShipwireResponse', ok?: true, body: shipwire_rate ) }
          let(:shipwire_api) { double('ShipwireApi', find: shipwire_response) }

          it 'return not found' do
            subject
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end
  end
end

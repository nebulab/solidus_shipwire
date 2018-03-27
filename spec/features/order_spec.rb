require 'spree/testing_support/order_walkthrough'

describe Spree::Order do
  context 'change phone_number',
    vcr: { cassette_name: 'spree/update_data_exists' } do
    let!(:order) { create(:order_with_line_items, state: :complete, shipwire_id: '92297445') }

    it 'update phone number' do
      expect(order.in_shipwire.ship_to['resource']['phone']).to eq '555-555-0199'

      order.ship_address_attributes = { phone: '123123123' }
      order.save
      order.reload
      expect(order.in_shipwire.ship_to['resource']['phone']).to eq '123123123'
    end
  end
end

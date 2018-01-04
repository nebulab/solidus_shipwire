require 'spree/testing_support/order_walkthrough'

describe Spree::Order do
  context 'order in confirm state',
    vcr: { cassette_name: 'spree/confirm_state' } do

    let!(:order) { OrderWalkthrough.up_to(:payment) }

    context 'have at least one variant synced in shipwire' do
      before do
        variant = order.line_items.first.variant
        variant.update_attribute(:shipwire_id, '229175')
      end

      context 'with specified shipwire_id' do
        before do
          order.update_attribute(:shipwire_id, '92297445')
        end

        it_behaves_like 'a shipwire object'
      end
    end
  end

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

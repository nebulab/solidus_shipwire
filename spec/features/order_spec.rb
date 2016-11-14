require 'spree/testing_support/order_walkthrough'

describe Spree::Order do
  let!(:order) { create(:order_with_line_items, state: :confirm) }

  context 'order in confirm state' do
    let!(:order) { OrderWalkthrough.up_to(:payment) }

    context 'have at least one variant synced in shipwire' do
      before do
        variant = order.line_items.first.variant
        variant.update_attribute(:shipwire_id, '123456')
      end

      it 'run sync when completed' do
        expect(order).to receive(:in_shipwire)

        order.complete!
      end
    end

    context 'without variant synced in shipwire' do
      it 'run sync when completed' do
        expect(order).to_not receive(:in_shipwire)

        order.complete!
      end
    end
  end

  it_behaves_like 'a shipwire object'
end

require 'spree/testing_support/order_walkthrough'

describe Spree::Order do
  let!(:order) { create(:order_with_line_items, state: :confirm) }

  context "order in confirm state" do
    let!(:order) { OrderWalkthrough.up_to(:payment) }

    it 'run sync when completed' do
      expect(order).to receive(:in_shipwire)
      order.complete!
    end
  end

  it_behaves_like 'a shipwire object'
end

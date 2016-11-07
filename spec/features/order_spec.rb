describe Spree::Order do
  let!(:order) { create(:order_with_line_items) }

  it_behaves_like 'a shipwire object'
end

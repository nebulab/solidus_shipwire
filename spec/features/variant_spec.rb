describe Spree::Variant do
  let!(:variant) { create(:variant) }

  it_behaves_like 'a shipwire object'
end

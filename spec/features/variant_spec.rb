describe Spree::Variant do
  let!(:variant) { create(:variant) }

  before do
    solidus_entity.sku = 'SKU-123354'
    solidus_entity.update_attribute(:shipwire_id, '229175')
  end

  it_behaves_like 'a shipwire object'
end

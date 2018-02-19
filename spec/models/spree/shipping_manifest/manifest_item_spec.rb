describe Spree::ShippingManifest::ManifestItem, type: :model do
  describe "#to_shipwire" do
    let(:variant) { create(:variant, shipwire_id: 1) }
    let(:inventory_unit) { create(:inventory_unit, variant: variant) }
    let(:line_item) { inventory_unit.line_item }

    subject { described_class.new(line_item, variant, 1, :on_hand).to_shipwire }

    it "returns inventory_units with shipwire_nil for shipwire_id" do
      expect(subject).to match(
        sku: variant.sku,
        quantity: line_item.quantity,
        commercialInvoiceValue: line_item.price,
        commercialInvoiceValueCurrency: 'USD'
      )
    end
  end
end

describe Spree::InventoryUnit, type: :model do
  describe "#eligible_for_shipwire" do
    before do
      create(:inventory_unit)
      create(:inventory_unit, variant: create(:variant, shipwire_id: 123_456))
    end

    subject { described_class.eligible_for_shipwire }

    it "returns only inventory_units with shipwire_id set" do
      expect(described_class.all.count).to eq 2
      expect(subject.count).to eq 1
      expect(subject.first.variant.shipwire_id).to eq 123_456
    end
  end
end

describe Spree::InventoryUnit, type: :model do
  describe "#eligible_for_shipwire" do
    let(:variant_eligible_for_shipwire) { create(:variant, shipwire_id: 1) }

    before do
      create(:inventory_unit)
      create(:inventory_unit, variant: variant_eligible_for_shipwire)
    end

    subject { described_class.eligible_for_shipwire }

    it "returns only inventory_units with shipwire_id not empty" do
      expect(subject.count).to eq 1
      expect(subject.first.variant.shipwire_id).to eq 1
    end
  end
end

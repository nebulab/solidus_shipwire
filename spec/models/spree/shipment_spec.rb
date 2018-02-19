describe Spree::Shipment, type: :model do
  describe "#to_shipwire" do
    let(:variant)         { create(:variant, shipwire_id: 1) }
    let(:inventory_unit)  { create(:inventory_unit, variant: variant) }
    let(:inventory_units) { [inventory_unit] }
    let(:shipment)        { create(:shipment, inventory_units: inventory_units) }
    let(:manifest_item)   { spy(:manifest_item, to_shipwire: {} ) }

    subject { shipment.to_shipwire }

    it "calls ShippingManifest::ManifestItem#to_shipwire" do
      allow(Spree::ShippingManifest::ManifestItem).to receive(:new) { manifest_item }
      expect(manifest_item).to receive(:to_shipwire)

      subject
    end

    context "process_after_date is set" do
      it "returns processAfterDate" do
        allow(shipment).to receive(:process_after_date) { "2018-01-01T12:00:00+01:00" }

        expect(subject).to include processAfterDate: "2018-01-01T12:00:00+01:00"
      end
    end

    context "contains only inventory units eligible_for_shipwire" do
      let(:variant_not_on_shipwire) { create(:variant) }

      let(:inventory_units) do
        [
          inventory_unit,
          not_eligible_for_shipwire
        ]
      end

      let(:not_eligible_for_shipwire) do
        create(:inventory_unit, variant: variant_not_on_shipwire)
      end

      it "calls to_shipwire only once" do
        expect(subject[:items].count).to eq 1
      end
    end
  end
end

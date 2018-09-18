describe Spree::Order do
  describe "#update_shipments_on_shipwire" do
    let(:shipment) { create(:shipment, shipwire_id: 123_456) }
    let(:order)    { shipment.order }

    before do
      allow(order).to receive(:complete?) { true }
    end

    subject { shipment.order.update_shipments_on_shipwire }

    it "is called after save" do
      expect(order).to receive(:update_shipments_on_shipwire)

      order.save
    end

    it "calls update_on_shipwire on shipments" do
      order.shipments.each do |shipment|
        expect(shipment).to receive(:update_on_shipwire)
      end

      subject
    end

    context "when order is not completed" do
      let(:order) { create(:order_ready_to_complete) }

      it "doesn't call update_on_shipwire on shipments" do
        order.shipments.each do |shipment|
          expect(shipment).not_to receive(:update_on_shipwire)
        end

        subject
      end
    end

    context "when shipments' shipwire_id are not set" do
      let(:shipment) { create(:shipment, shipwire_id: nil) }

      it "doesn't call update_on_shipwire on shipments" do
        order.shipments.each do |shipment|
          expect(shipment).not_to receive(:update_on_shipwire)
        end

        subject
      end
    end
  end
end

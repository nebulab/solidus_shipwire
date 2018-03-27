class FakeShipwireApi < Shipwire::Api; end





describe SolidusShipwire::Shipwireable::ShipwireApi do
  context "when api_class is configured" do
    let(:dummy_class) do
      Class.new do
        extend SolidusShipwire::Shipwireable

        acts_as_shipwireable api_class: FakeShipwireApi
      end
    end

    let(:described_class) { dummy_class }

    it_behaves_like "shipwire api shipwireable"
    it_behaves_like "shipwire integrated object"
  end
end

class FakeShipwireSerializer < ActiveModel::Serializer; end

shared_examples "shipwire serializer shipwireable" do
  subject { described_class.new }

  %w(
    to_shipwire_json
  ).each do |method|
    it { is_expected.to respond_to method }
  end

  describe "#to_shipwire_json" do
    let(:shipwire_serializer) { double(as_json: {}) }

    subject { described_class.new.to_shipwire_json }

    it "calls as_json on serializer" do
      expect(described_class.shipwire_serializer).to receive(:new)
        .and_return(shipwire_serializer)
      expect(shipwire_serializer).to receive(:as_json)

      subject
    end
  end
end

describe SolidusShipwire::Shipwireable::ShipwireSerializer do
  context "when serializer is configured" do
    let(:dummy_class) do
      Class.new do
        extend SolidusShipwire::Shipwireable

        acts_as_shipwireable serializer: FakeShipwireSerializer
      end
    end

    let(:described_class) { dummy_class }

    it_behaves_like "shipwire serializer shipwireable"
  end
end

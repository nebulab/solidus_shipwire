class FakeShipwireApi < Shipwire::Api; end

shared_examples "shipwire api shipwireable" do
  subject { described_class }

  %w(
    shipwire_api
  ).each do |method|
    it { is_expected.to respond_to method }
  end
end

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
  end
end

class FakeShipwireApi < Shipwire::Api; end

shared_examples "shipwire api shipwireable" do
  subject { described_class }

  %w(
    shipwire_api
    find_on_shipwire
    update_on_shipwire
  ).each do |method|
    it { is_expected.to respond_to method }
  end

  describe ".find_on_shipwire" do
    let(:shipwire_id)       { '1234567' }
    let(:shipwire_response) { Shipwire::Response.new }

    subject { described_class.find_on_shipwire(shipwire_id) }

    it "calls find on shipwire_api" do
      expect(described_class.shipwire_api).to receive(:find)
        .with(shipwire_id)
        .and_return(shipwire_response)

      is_expected.to be_a Shipwire::Response
    end
  end

  describe ".update_on_shipwire" do
    let(:shipwire_id)       { '1234567' }
    let(:shipwire_json)     { {} }
    let(:shipwire_response) { Shipwire::Response.new }

    subject { described_class.update_on_shipwire(shipwire_id, shipwire_json) }

    it "calls update on shipwire_api" do
      expect(described_class.shipwire_api).to receive(:update)
        .with(shipwire_id, shipwire_json)
        .and_return(shipwire_response)

      is_expected.to be_a Shipwire::Response
    end
  end

  describe ".create_on_shipwire" do
    let(:shipwire_json)     { {} }
    let(:shipwire_response) { Shipwire::Response.new }

    subject { described_class.create_on_shipwire(shipwire_json) }

    it "calls create on shipwire_api" do
      expect(described_class.shipwire_api).to receive(:create)
        .with(shipwire_json)
        .and_return(shipwire_response)

      is_expected.to be_a Shipwire::Response
    end
  end
end

shared_examples "shipwire integrated object" do
  let(:shipwire_id)        { '1234567' }
  let(:shipwire_json)      { {} }
  let(:shipwire_response)  { Shipwire::Response.new }
  let(:described_instance) { described_class.new }

  before do
    allow(described_instance).to receive(:shipwire_id).and_return(shipwire_id)
    allow(described_instance).to receive(:to_shipwire_json)
      .and_return(shipwire_json)
  end

  %w(
    find_on_shipwire
    update_on_shipwire
  ).each do |method|
    it { is_expected.to respond_to method }
  end

  describe "#find_on_shipwire" do
    subject { described_instance.find_on_shipwire }

    it "calls find_on_shipwire on #{described_class}" do
      expect(described_class).to receive(:find_on_shipwire)
        .with(shipwire_id)
        .and_return(shipwire_response)

      is_expected.to be_a Shipwire::Response
    end
  end

  describe "#update_on_shipwire" do
    subject { described_instance.update_on_shipwire }

    it "calls update_on_shipwire on #{described_class}" do
      expect(described_class).to receive(:update_on_shipwire)
        .with(shipwire_id, shipwire_json)
        .and_return(shipwire_response)

      is_expected.to be_a Shipwire::Response
    end
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
    it_behaves_like "shipwire integrated object"
  end
end

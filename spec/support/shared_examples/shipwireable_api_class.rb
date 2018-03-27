shared_examples "shipwireable api class" do
  subject { described_class }

  %w(
    shipwire_api
    find_on_shipwire
    update_on_shipwire
  ).each do |method|
    it { is_expected.to respond_to method }
  end

  describe "api_class #{described_class.shipwire_api.class} defines shipwire api methods" do
    subject { described_class.shipwire_api }

    %w(
      find
      create
      update
    ).each do |method|
      it { is_expected.to respond_to method }
    end
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

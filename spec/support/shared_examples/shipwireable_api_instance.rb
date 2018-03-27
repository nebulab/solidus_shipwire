shared_examples "shipwireable api instance" do
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
    create_on_shipwire
    find_or_create_on_shipwire
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

  describe "#update_shipwire_id" do
    subject { described_instance.update_shipwire_id(shipwire_id) }

    context "when is persisted" do
      it "update_column on database" do
        expect(described_instance).to receive(:persisted?) { true }
        expect(described_instance).to receive(:update_column).with(:shipwire_id, shipwire_id)

        subject
      end
    end

    context "when is not persisted" do
      it "update shipwire id attribute" do
        expect(described_instance).to receive(:persisted?) { false }
        expect(described_instance).not_to receive(:update_column)
        expect(described_instance).to receive(:shipwire_id=).with(shipwire_id)

        subject
      end
    end
  end

  describe "#create_on_shipwire" do
    subject { described_instance.create_on_shipwire }

    before do
      expect(described_class).to receive(:create_on_shipwire)
        .with(shipwire_json)
        .and_return(shipwire_response)
    end

    context "when is not successful on shipwire" do
      let(:shipwire_response) do
        instance_double("Shipwire::Response", ok?: false, error_report: "error")
      end

      it { expect{ subject }.to raise_error(SolidusShipwire::ResponseException) }
    end

    context "when is successful on shipwire" do
      before do
        expect(described_instance).to receive(:find_on_shipwire)
          .with(shipwire_id)
          .and_return(shipwire_response)
        expect(described_instance).to receive(:update_shipwire_id).with(shipwire_id)
      end
    end
  end

  describe "#find_or_create_on_shipwire" do
    let(:shipwire_response) { Shipwire::Response.new }

    subject { described_instance.find_or_create_on_shipwire }

    before do
      expect(described_class).to receive(:find_on_shipwire)
        .with(shipwire_id)
        .and_return(shipwire_response)
    end

    context "when already exists on shipwire" do
      before { expect(shipwire_response).to receive(:ok?) { true } }

      it { is_expected.to be_a Shipwire::Response }
    end

    context "when is not found on shipwire" do
      before { expect(shipwire_response).to receive(:ok?) { false } }

      it "calls create_on_shipwire" do
        expect(described_class).to receive(:create_on_shipwire)
          .with(shipwire_json)
          .and_return(Shipwire::Response.new)

        is_expected.to be_a Shipwire::Response
      end
    end
  end
end

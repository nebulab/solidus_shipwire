shared_examples "shipwireable api instance" do
  let(:shipwire_id)        { '1234567' }
  let(:shipwire_json)      { {} }
  let(:shipwire_response)  { Shipwire::Response.new }
  let(:described_instance) { described_class.new }
  let(:api_class)          { instance_double('Shipwire Api') }

  let(:underlying_response) do
    double("response", body:
      { resource: { items: [{ resource: { id: 123_456 } }] } }.to_json
    )
  end


  before do
    allow(described_class).to receive(:shipwire_api) { api_class }
    allow(described_instance).to receive(:shipwire_id) { shipwire_id }
    allow(described_instance).to receive(:to_shipwire_json) { shipwire_json }
  end

  describe "#find_on_shipwire" do
    subject { described_instance.find_on_shipwire }

    it "calls find_on_shipwire on #{described_class}" do
      expect(described_class).to receive(:find_on_shipwire)
        .with(shipwire_id).and_return(shipwire_response)

      is_expected.to be_a Shipwire::Response
    end

    context "when it fails" do
      let(:shipwire_response) do
        instance_double("Shipwire response", ok?: false, error_report: "report")
      end

      it "raises an error" do
        expect(described_class).to receive(:find_on_shipwire)
          .with(shipwire_id).and_return(shipwire_response)

        expect{ subject }.to raise_error(
          SolidusShipwire::ResponseException, "report"
        )
      end
    end
  end

  describe "#update_on_shipwire" do
    subject { described_instance.update_on_shipwire }

    it "calls update_on_shipwire on #{described_class}" do
      expect(described_class).to receive(:update_on_shipwire)
        .with(shipwire_id, shipwire_json).and_return(shipwire_response)

      is_expected.to be_a Shipwire::Response
    end

    context "when shipwire_id is nil" do
      let(:shipwire_id) { nil }
      it { expect{ subject }.to raise_error(RuntimeError) }
    end
  end

  describe "#update_on_shipwire!" do
    subject { described_instance.update_on_shipwire! }

    before do
      allow(described_instance).to receive(:update_on_shipwire) { response }
    end

    context "when is a success" do
      let(:response) { OpenStruct.new(ok?: true) }

      it "returns the shipwire object" do
        is_expected.to eq(response)
      end
    end

    context "when it fails" do
      let(:response) { OpenStruct.new(ok?: false, error_report: "report") }

      it "raises an error" do
        expect{subject}.to raise_error(
          SolidusShipwire::ResponseException, "report"
        )
      end
    end
  end

  describe "#update_shipwire_id" do
    subject { described_instance.update_shipwire_id(shipwire_id) }

    context "when is persisted" do
      it "update_column on database" do
        expect(described_instance).to receive(:persisted?) { true }
        expect(described_instance).to receive(:update_column)
          .with(:shipwire_id, shipwire_id)

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

    let(:shipwire_response) do
      Shipwire::Response.new(underlying_response: underlying_response)
    end

    it "calls the shipwire create with the json data" do
      expect(described_class).to receive(:create_on_shipwire)
        .with(shipwire_json).and_return(shipwire_response)

      is_expected.to be_a Shipwire::Response
    end
  end

  describe "#create_on_shipwire!" do
    subject { described_instance.create_on_shipwire! }

    before do
      allow(described_instance).to receive(:create_on_shipwire) { response }
    end

    context "when is a success" do
      let(:response) { OpenStruct.new(ok?: true) }

      it "returns the shipwire object" do
        is_expected.to eq(response)
      end
    end

    context "when it fails" do
      let(:response) { OpenStruct.new(ok?: false, error_report: "report") }

      it "raises an error" do
        expect{subject}.to raise_error(
          SolidusShipwire::ResponseException, "report"
        )
      end
    end
  end

  describe "#find_or_create_on_shipwire" do
    subject { described_instance.find_or_create_on_shipwire }

    context "when shipwire id is present" do
      before do
        expect(described_instance).to receive(:shipwire_id) { 123_456 }
        expect(described_instance).to receive(:find_on_shipwire)
          .and_return(shipwire_response)
      end

      it { is_expected.to be_a Shipwire::Response }
    end

    context "when shipwire id is not present" do
      before do
        expect(described_instance).to receive(:shipwire_id) { nil }
        expect(described_instance).to receive(:create_on_shipwire)
          .and_return(shipwire_response)
      end

      it { is_expected.to be_a Shipwire::Response }
    end
  end

  describe "#find_or_create_on_shipwire!" do
    subject { described_instance.find_or_create_on_shipwire! }

    context "when shipwire id is present" do
      before { allow(described_instance).to receive(:shipwire_id) { 123_456 } }

      it "calls find_on_shipwire!" do
        expect(described_instance).to receive(:find_on_shipwire)
          .and_return(shipwire_response)

        expect(subject).to be_a Shipwire::Response
      end
    end

    context "when shipwire id is not present" do
      before { allow(described_instance).to receive(:shipwire_id) { nil } }

      it "calls create_on_shipwire!" do
        expect(described_instance).to receive(:create_on_shipwire!)
          .and_return(shipwire_response)

        expect(subject).to be_a Shipwire::Response
      end
    end
  end
end

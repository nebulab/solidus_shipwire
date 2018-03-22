shared_examples "is not overrided" do
  it { expect{ subject }.to raise_error(NameError) }
end

describe SolidusShipwire::Proxy do
  let(:dummy_class)           { Class.new { prepend SolidusShipwire::Proxy } }
  let(:dummy_instance)        { dummy_class.new }
  let(:shipwire_response)     { Shipwire::Response.new }
  let(:shipwire_id)           { '123456' }
  let(:shipwire_instance_api) { double('shipwire api instance', find: shipwire_response) }

  describe "#to_shipwire_object" do
    subject { dummy_instance.to_shipwire_object({}) }

    it_behaves_like "is not overrided"

    context "when to_shipwire_object is overrided" do
      let(:dummy_class) do
        Class.new do
          prepend SolidusShipwire::Proxy

          def to_shipwire_object(_)
            true
          end
        end
      end

      it { expect{ subject }.not_to raise_error }
    end
  end

  describe "#shipwire_instance" do
    subject { dummy_instance.shipwire_instance }

    it_behaves_like "is not overrided"

    context "when shipwire_instance is overrided" do
      let(:dummy_class) do
        Class.new do
          prepend SolidusShipwire::Proxy

          def shipwire_instance
            true
          end
        end
      end

      it { expect{ subject }.not_to raise_error }
    end
  end

  describe "#find_on_shipwire" do
    subject { dummy_instance.find_on_shipwire(shipwire_id) }

    before do
      expect(shipwire_instance_api).to receive(:find).with(shipwire_id)
      expect(dummy_instance).to receive(:shipwire_instance) { shipwire_instance_api }
    end

    it { is_expected.to be_a Shipwire::Response }
  end

  describe "#update_shipwire_id" do
    subject { dummy_instance.update_shipwire_id(shipwire_id) }

    context "when is persisted" do
      it "update_column on database" do
        expect(dummy_instance).to receive(:persisted?) { true }
        expect(dummy_instance).to receive(:update_column).with(:shipwire_id, shipwire_id)
        subject
      end
    end

    context "when is not persisted" do
      it "update shipwire id attribute" do
        expect(dummy_instance).to receive(:persisted?) { false }
        expect(dummy_instance).not_to receive(:update_column)
        expect(dummy_instance).to receive(:shipwire_id=).with(shipwire_id)
        subject
      end
    end
  end

  describe "#create_on_shipwire" do
    before do
      expect(dummy_instance).to receive(:to_shipwire) { {} }
      expect(dummy_instance).to receive(:shipwire_instance) do
        double('shipwire api instance', create: shipwire_response)
      end
    end

    subject { dummy_instance.create_on_shipwire }

    context "when is not successful on shipwire" do
      let(:shipwire_response) do
        instance_double("Shipwire::Response", ok?: false, error_report: "error")
      end

      it { expect{ subject }.to raise_error(SolidusShipwire::ResponseException) }
    end

    context "when is successful on shipwire" do
      let(:response_body) do
        { "resource" => { "items" => [{ "resource" => { "id" => shipwire_id } }] } }
      end

      let(:shipwire_response) do
        instance_double("Shipwire::Response", ok?: true, body: response_body)
      end

      before do
        expect(dummy_instance).to receive(:update_shipwire_id).with(shipwire_id)
        expect(dummy_instance).to receive(:find_on_shipwire)
          .with(shipwire_id)
          .and_return(Shipwire::Response.new)
      end

      it { is_expected.to be_a Shipwire::Response }
    end
  end

  describe "#find_or_create_on_shipwire_api" do
    let(:body_response) { { "resource" => "shipwire data" } }

    let(:shipwire_response) do
      instance_double("Shipwire::Response", ok?: success, body: body_response)
    end

    subject { dummy_instance.find_or_create_on_shipwire_api(shipwire_id) }

    before do
      expect(dummy_instance).to receive(:find_on_shipwire)
        .with(shipwire_id)
        .and_return(shipwire_response)
    end

    context "object exists on shipwire" do
      let(:success) { false }

      before do
        expect(dummy_instance).to receive(:create_on_shipwire)
          .with(no_args)
          .and_return(shipwire_response)
      end

      context "when to_shipwire_object" do
        it_behaves_like "is not overrided"
      end

      context "when to_shipwire_object is overrided" do
        before do
          expect(dummy_instance).to receive(:to_shipwire_object)
            .with("shipwire data")
            .and_return("SolidusShipwire::ShipwireObjects::Instance")
        end

        it { is_expected.to eq "SolidusShipwire::ShipwireObjects::Instance" }
      end
    end

    context "object doesn't exist on shipwire" do
      let(:success) { true }

      context "when to_shipwire_object" do
        it_behaves_like "is not overrided"
      end

      context "when to_shipwire_object is overrided" do
        before do
          expect(dummy_instance).to receive(:to_shipwire_object)
            .with("shipwire data")
            .and_return("SolidusShipwire::ShipwireObjects::Instance")
        end

        it { is_expected.to eq "SolidusShipwire::ShipwireObjects::Instance" }
      end
    end
  end

  describe "#update_on_shipwire" do
    subject { dummy_instance.update_on_shipwire }

    let(:shipwire_json_data) { { "" => "shipwire_json_data" } }

    before do
      expect(dummy_instance).to receive(:shipwire_id) { shipwire_id }
      expect(dummy_instance).to receive(:to_shipwire) { shipwire_json_data }
      expect(shipwire_instance_api).to receive(:update)
        .with(shipwire_id, shipwire_json_data)
        .and_return(Shipwire::Response.new)
      expect(dummy_instance).to receive(:shipwire_instance) { shipwire_instance_api }
    end

    it { is_expected.to be_a Shipwire::Response }
  end

  describe "#in_shipwire" do
    subject { dummy_instance.in_shipwire }

    context "when shipwire_id is missed" do
      it_behaves_like "is not overrided"
    end

    context "when shipwire_id is defined" do
      before do
        expect(dummy_instance).to receive(:find_or_create_on_shipwire_api)
          .and_return "SolidusShipwire::ShipwireObjects::Instance"
        expect(dummy_instance).to receive(:shipwire_id).and_return shipwire_id
      end

      it { is_expected.to eq "SolidusShipwire::ShipwireObjects::Instance" }
    end
  end
end

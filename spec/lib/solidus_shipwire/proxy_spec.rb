shared_examples "is not overrided" do
  it { expect{ subject }.to raise_error(NameError) }
end

describe SolidusShipwire::Proxy do
  let(:dummy_class)           { Class.new { prepend SolidusShipwire::Proxy } }
  let(:dummy_instance)        { dummy_class.new }
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
end

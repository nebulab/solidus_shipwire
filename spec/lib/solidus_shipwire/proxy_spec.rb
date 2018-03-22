shared_examples "is not overrided" do
  it { expect{ subject }.to raise_error(NameError) }
end

describe SolidusShipwire::Proxy do
  let(:dummy_class)           { Class.new { prepend SolidusShipwire::Proxy } }
  let(:dummy_instance)        { dummy_class.new }

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
end

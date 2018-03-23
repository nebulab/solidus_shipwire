describe SolidusShipwire::Shipwireable do
  context "when Shipwireable extends a class" do
    let(:dummy_class) do
      Class.new do
        extend SolidusShipwire::Shipwireable
      end
    end

    let(:dummy_instance) { dummy_class.new }

    subject { dummy_class }

    it { is_expected.to respond_to :acts_as_shipwireable }

    context ".acts_as_shipwireable" do
      let(:shipwireable_config) { { config: :value } }
      subject { dummy_class.acts_as_shipwireable(shipwireable_config) }

      let(:dummy_class) do
        Class.new do
          extend SolidusShipwire::Shipwireable
        end
      end

      it "sets shipwireable_config class variable" do
        subject
        expect(dummy_class.shipwireable_config).to eq shipwireable_config
      end
    end
  end
end

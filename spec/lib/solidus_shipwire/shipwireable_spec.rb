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
  end
end

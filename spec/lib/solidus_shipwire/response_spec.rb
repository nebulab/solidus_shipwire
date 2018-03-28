describe Shipwire::Response, type: :model do
  let(:response_instance) do
    described_class.new(underlying_response: underlying_response)
  end

  let(:underlying_response) do
    double("response", body: { resource: resource }.to_json)
  end

  describe "#resource" do
    subject { response_instance.resource }

    let(:resource) { double("resource") }

    it "returns body[:resource] with indifferent access" do
      expect(subject).to be_a HashWithIndifferentAccess
    end
  end

  describe "#next" do
    subject { response_instance.next? }

    context "when there is a next resource" do
      let(:resource) { { next: true } }

      it { is_expected.to be_truthy }
    end

    context "when there isn't a next resource" do
      let(:resource) { { next: false } }

      it { is_expected.to be_falsey }
    end
  end

  describe "#to_sku_id_hashmap" do
    subject { response_instance.to_sku_id_hashmap }

    let(:resource) do
      { items: [{ resource: { sku: "sku1", id: 1 } },
                { resource: { sku: "sku2", id: 2 } }] }
    end

    let(:expected_hash) { { "sku1" => 1, "sku2" => 2 } }

    it "remaps the hash correctly" do
      expect(subject).to eq expected_hash
    end
  end
end

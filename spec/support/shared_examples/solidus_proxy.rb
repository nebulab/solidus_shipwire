shared_examples_for 'a shipwire object' do
  let(:solidus_entity) { described_class.first }

  describe '#in_shipwire' do
    subject { solidus_entity.in_shipwire }

    context 'with an item that is not in the collection',
            vcr: { cassette_name: "#{described_class.name.underscore}_create_entity" } do
      before do
        solidus_entity.shipwire_id = nil
      end

      it 'create on shipwire' do
        expect(solidus_entity).to receive(:create_on_shipwire).and_call_original
        subject
      end
    end
  end
end

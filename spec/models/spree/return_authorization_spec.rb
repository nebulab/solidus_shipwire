# Due to the future refactoring of returns these specs are pending until
# returns logic is complete.
xdescribe Spree::ReturnAuthorization, type: :model do
  let(:default_warehouse)    { ShipwireFactory::Warehouse.new.default }
  let(:shipwire_product)     { sw_product_factory.in_stock }
  let(:return_item)          { build(:return_item, inventory_unit: order.inventory_units.first) }
  let(:return_items)         { [return_item] }
  let(:return_authorization) { build(:return_authorization, order: order, return_items: return_items) }
  let(:product)              { create(:product, sku: shipwire_product['sku']) }

  let(:variant) do
    product.master.tap { |master| master.update_attributes(shipwire_id: shipwire_product['id']) }
  end

  before do
    Spree::ShipwireConfig.default_warehouse_id = default_warehouse['id']
  end

  describe "order in pending state",
           vcr: { cassette_name: 'spree/return_authorization_not_returnable' } do

    let(:order) do
      create(:shipped_order,
             :pending_on_shipwire,
             line_items_attributes: [product: variant.product])
    end

    # Only orders that are processed and not cancelled can be returned
    it 'does not accept the return' do
      allow(return_authorization).to receive(:process_shipwire_return!).and_call_original

      return_authorization.save

      expect(return_authorization).to have_received(:process_shipwire_return!)
      expect(return_authorization.errors.messages).to have_key(:shipwire_unprocessed)
      expect(return_authorization.errors.messages[:shipwire_unprocessed].first).to eq("Only orders that are \"processed\" and not \"cancelled\" can be returned")
    end
  end

  context "order marked as shipped on shipwire",
          vcr: { cassette_name: 'spree/return_authorization_create_entity_single_return_item' } do
    let(:order) do
      create(:shipped_order,
             :shipped_on_shipwire,
             line_items_attributes: [product: variant.product])
    end

    it 'post to shipwire' do
      allow(return_authorization).to receive(:process_shipwire_return!).and_call_original
      return_authorization.save

      expect(return_authorization).to have_received(:process_shipwire_return!)
      expect(return_authorization.errors.messages).to be_empty
      expect(return_authorization.shipwire_id).not_to be_nil
    end

    context 'and a return was already reported',
            vcr: { cassette_name: 'spree/return_authorization_entity_exists' } do
      before do
        Shipwire::Returns.new.create(return_authorization.to_shipwire)
      end

      it 'add an error message' do
        return_authorization.save

        expect(return_authorization.errors.messages).to have_key(:shipwire_already_reported)
        expect(return_authorization.errors.messages[:shipwire_already_reported].first).to eq('You have already reported this issue.')
      end
    end

    context 'when generic errors occurs' do
      context 'when timeout occurs',
              vcr: { cassette_name: 'spree/return_authorization_generic_error' } do
        let(:request) { Shipwire::Request.new }

        before do
          # Create the order on shipwire before stub a timeout error
          order

          allow(request).to receive(:build_connection)

          allow(Shipwire::Request)
            .to receive(:new)
            .with(hash_including(method: :post))
            .and_return(request)

          allow(Shipwire::Request)
            .to receive(:new)
            .with(hash_including(method: :get))
            .and_call_original

          allow(request).to receive(:make_request).and_raise(Faraday::TimeoutError)
        end

        it 'add a timeout error' do
          return_authorization.save

          expect(return_authorization.errors.messages).to have_key(:shipwire_timeout)
        end
      end
    end

    context "with multiple return items",
            vcr: { cassette_name: 'spree/return_authorization_create_entity_multiple_return_item' } do
      let(:shipwire_product2) { sw_product_factory.in_stock(sku: 'product2-in') }
      let(:return_item2)      { build(:return_item, inventory_unit: order.inventory_units.second) }
      let(:return_items)      { [return_item, return_item2] }
      let(:product2)          { create(:product, sku: shipwire_product2['sku']) }

      let(:variant2) do
        product2.master.tap { |master| master.update_attributes(shipwire_id: shipwire_product2['id']) }
      end

      let(:order) do
        create(:shipped_order,
               :shipped_on_shipwire,
               line_items_count: 2,
               line_items_attributes: [{ product: variant.product }, { product: variant2.product }])
      end

      it 'post to shipwire' do
        allow(return_authorization).to receive(:process_shipwire_return!).and_call_original

        return_authorization.save

        expect(return_authorization).to have_received(:process_shipwire_return!)
        expect(return_authorization.errors.messages).to be_empty
        expect(return_authorization.shipwire_id).not_to be_nil
      end
    end
  end
end

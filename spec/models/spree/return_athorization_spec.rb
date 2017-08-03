describe Spree::ReturnAuthorization, type: :model do
  let(:shipwire_ids) { YAML.load_file(File.expand_path('../../../fixtures/files/shipwire_order_ids.yml', __FILE__)) }
  let(:variant_skus) { YAML.load_file(File.expand_path('../../../fixtures/files/shipwire_variant_skus.yml', __FILE__)) }

  # An order on Shipwire in pending state
  let(:pending_order) { shipwire_ids['pending_order'] }
  # An order on Shipwire in shipped state (contains 1*variant_1)
  let(:shipped_order_single_return_item) { shipwire_ids['shipped_order_single_return_item'] }
  # An order on Shipwire in shipped state (contains 2*variant_1 and 2*variant_2)
  let(:shipped_order_multiple_return_items) { shipwire_ids['shipped_order_multiple_return_items'] }
  # An order on Shipwire that was already been reported)
  let(:already_returned_order) { shipwire_ids['already_returned_order'] }

  let(:variant_1) { build(:variant, sku: variant_skus['sku_1']) }
  let(:variant_2) { build(:variant, sku: variant_skus['sku_2']) }

  let(:return_authorization) { build(:return_authorization) }

  context 'when posting a return to shipwire' do
    context 'when shipwire does not accept the return' do
      context 'when a shipwire order is in a not returnable state (Only orders that are processed and not cancelled can be returned)',
              vcr: { cassette_name: 'spree/return_authorization_not_returnable' } do

        let(:inventory_unit)  { build(:inventory_unit, variant: variant_2) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { pending_order }
        let(:return_items)    { [return_item] }

        before do
          return_authorization.return_items = return_items
          return_authorization.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'post to shipwire' do
          expect(return_authorization).to receive(:process_shipwire_return!).and_call_original

          return_authorization.save
        end

        it 'add an error message' do
          return_authorization.save

          expect(return_authorization.errors.messages).to have_key(:shipwire_unprocessed)
          expect(return_authorization.errors.messages[:shipwire_unprocessed].first).to eq("Only orders that are \"processed\" and not \"cancelled\" can be returned")
        end
      end

      context 'when a return for the order was already been reported',
              vcr: { cassette_name: 'spree/return_authorization_entity_exists' } do

        let(:inventory_unit)  { build(:inventory_unit, variant: variant_1) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { already_returned_order }
        let(:return_items)    { [return_item] }

        before do
          return_authorization.return_items = return_items
          return_authorization.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'add an error message' do
          return_authorization.save

          expect(return_authorization.errors.messages).to have_key(:shipwire_already_reported)
          expect(return_authorization.errors.messages[:shipwire_already_reported].first).to eq('You have already reported this issue.')
        end
      end
    end

    context 'when shipwire does accept the return' do
      context 'when return has 1 return item',
              vcr: { cassette_name: 'spree/return_authorization_create_entity_single_return_item' } do

        let(:inventory_unit)  { build(:inventory_unit, variant: variant_1) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { shipped_order_single_return_item }
        let(:return_items)    { [return_item] }
        let(:items_array)     { [{ sku: variant_1.sku, quantity: 1 }] }

        before do
          return_authorization.return_items = return_items

          return_authorization.order.shipments.first.ship
          return_authorization.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'post to shipwire' do
          expect(return_authorization).to receive(:process_shipwire_return!).and_call_original
          return_authorization.save
          expect(return_authorization.shipwire_id).not_to be nil
        end

        it 'places a single item in the return' do
          expect(return_authorization.to_shipwire[:items]).to eq items_array
        end
      end

      context 'when return has multiple return items',
              vcr: { cassette_name: 'spree/return_authorization_create_entity_multiple_return_items' } do

        let(:inventory_unit_1) { build(:inventory_unit, variant: variant_1) }
        let(:inventory_unit_2) { build(:inventory_unit, variant: variant_2, order: inventory_unit_1.order) }
        let(:return_item_1) { build(:return_item, inventory_unit: inventory_unit_1) }
        let(:return_item_2) { build(:return_item, inventory_unit: inventory_unit_2) }
        let(:return_item_3) { build(:return_item, inventory_unit: inventory_unit_2) }
        let(:shipwire_id)   { shipped_order_multiple_return_items }
        let(:return_items)  { [return_item_1, return_item_2, return_item_3] }
        let(:items_array)   { [{ sku: variant_1.sku, quantity: 1 }, { sku: variant_2.sku, quantity: 2 }] }

        before do
          return_authorization.return_items = return_items
          return_authorization.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'post to shipwire' do
          expect(return_authorization).to receive(:process_shipwire_return!).and_call_original
          return_authorization.save
          expect(return_authorization.shipwire_id).not_to be nil
        end

        it 'places multiple items in the return' do
          expect(return_authorization.to_shipwire[:items]).to eq items_array
        end
      end
    end

    context 'when generic errors occurs' do

      let(:inventory_unit)  { build(:inventory_unit, variant: variant_1) }
      let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
      let(:shipwire_id)     { shipped_order_single_return_item }
      let(:return_items)    { [return_item] }
      let(:request) { Shipwire::Request.new }

      before do
        return_authorization.return_items = return_items
        return_authorization.order.update_attribute(:shipwire_id, shipwire_id)

        allow(request).to receive(:build_connection)

        allow(Shipwire::Request)
          .to receive(:new)
          .with(hash_including(method: :post))
          .and_return(request)

        allow(Shipwire::Request)
          .to receive(:new)
          .with(hash_including(method: :get))
          .and_call_original
      end

      context 'when the response has 500 status code with included Something went wrong message',
              vcr: { cassette_name: 'spree/return_authorization_error_500' },
              skip: 'Need to find a way to stub the response with status 500 only for POST return request' do

        before do
          allow(request).to receive(:make_request).and_return(Faraday::Response.new())
        end

        it 'add a generic error' do
          return_authorization.save
          expect(return_authorization.errors.messages).to have_key(:shipwire_something_went_wrong)
        end
      end

      context 'when timeout occurs',
              vcr: { cassette_name: 'spree/return_authorization_timeout_error' } do

        before do
          allow(request).to receive(:make_request).and_raise(Faraday::TimeoutError)
        end

        it 'add a timeout error' do
          return_authorization.save
          expect(return_authorization.errors.messages).to have_key(:shipwire_timeout)
        end
      end
    end
  end
end

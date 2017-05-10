describe Spree::CustomerReturn, type: :model do

  # => Actually, just in case you want to regenerate vcr you must manually
  # => create 4 different orders and update its state on shipwire. You must then edit
  # => all the static (let) skus and shipwire_ids, providing real skus for
  # => variants that are part of the orders, and shipwire_ids for the created orders.

  # TODO: Dynamic order creation and state update via Shipwire API
  # => For the purpose of these tests we should dinamically create 4 orders
  # => 1 -  Create a complete order that contains 1 line item with variant with sku_1
  # => 2 -  Create a complete order that contains 1 line item with variant with sku_1, quantity: 1
  # =>      and after save mark it as Shipped on shipwire (via api)
  # => 4 -  Create a complete order that contains 1 line item with variant with sku_1, quantity: 2,
  # =>      1 line item with variant with sku_2, quantity: 2
  # =>      and after save mark it as Shipped on shipwire (via api)
  # => 3 -  Create a complete order that contains 1 line item with variant with sku_1
  # =>      and after save mark it as Shipped on shipwire and then return it (via api)

  let(:sku_variant_1) { 'F002-14' }
  let(:sku_variant_2) { 'F004-10' }
  let(:pending_order_shipwire_id)   { '92467126' } # An order on Shipwire in pending state
  let(:shipped_order_shipwire_id_1) { '92468844' } # An order on Shipwire in shipped state (with at least 1*variant_1)
  let(:shipped_order_shipwire_id_2) { '92468860' } # An order on Shipwire in shipped state (with at least 2*variant_1 and 2*variant_2)
  let(:returned_order_shipwire_id)  { '92467079' } # An order on Shipwire that was already been reported)

  let(:variant_1) { build(:variant, sku: 'F002-14') }
  let(:variant_2) { build(:variant, sku: 'F004-10') }

  context 'when posting a return to shipwire' do
    context "when shipwire does not accept the return" do
      context "when a shipwire order is in a not returnable state (Only orders that are processed and not cancelled can be returned)",
              vcr: { cassette_name: 'spree/customer_return_not_returnable' } do

        let(:customer_return) { build(:customer_return) }
        let(:inventory_unit)  { build(:inventory_unit, variant: variant_2) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { pending_order_shipwire_id }
        let(:return_items)    { [return_item] }

        before do
          customer_return.return_items = return_items
          customer_return.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'will post to shipwire' do
          expect(customer_return).to receive(:process_shipwire_return!).and_call_original
          customer_return.save!
        end

        it 'add an error message' do
          customer_return.save!
          expect(customer_return.errors.messages).to have_key(:shipwire)
        end
      end


      context 'when a return for the order was already been reported.)',
              vcr: { cassette_name: 'spree/customer_return_entity_exists' } do

        let(:customer_return) { build(:customer_return) }
        let(:inventory_unit)  { build(:inventory_unit, variant: variant_1) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { returned_order_shipwire_id }
        let(:return_items)    { [return_item] }

        before do
          customer_return.return_items = return_items
          customer_return.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'add an error message' do
          customer_return.save!
          expect(customer_return.errors.messages).to have_key(:shipwire)
        end
      end
    end

    context "when shipwire does accept the return" do
      context 'when return has 1 return item',
              vcr: { cassette_name: 'spree/customer_return_create_entity_single_return_item' } do

        let(:customer_return) { build(:customer_return) }
        let(:inventory_unit)  { build(:inventory_unit, variant: variant_1) }
        let(:return_item)     { build(:return_item, inventory_unit: inventory_unit) }
        let(:shipwire_id)     { shipped_order_shipwire_id_1 }
        let(:return_items)    { [return_item] }

        before do
          customer_return.return_items = return_items
          customer_return.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'will post to shipwire' do
          expect(customer_return).to receive(:process_shipwire_return!).and_call_original
          customer_return.save!
        end

        it 'will update the shipwire_id' do
          customer_return.save!
          expect(customer_return.shipwire_id).not_to be nil
        end
      end

      context 'when return has multiple return items',
              vcr: { cassette_name: 'spree/customer_return_create_entity_multiple_return_items' } do

        let(:customer_return) { build(:customer_return) }
        let(:inventory_unit_1) { build(:inventory_unit, variant: variant_1) }
        let(:inventory_unit_2) { build(:inventory_unit, variant: variant_2, order: inventory_unit_1.order) }
        let(:return_item_1) { build(:return_item, inventory_unit: inventory_unit_1) }
        let(:return_item_2) { build(:return_item, inventory_unit: inventory_unit_2) }
        let(:shipwire_id)   { shipped_order_shipwire_id_2 }
        let(:return_items)  { [return_item_1, return_item_1, return_item_2, return_item_2] }

        before do
          customer_return.return_items = return_items
          customer_return.order.update_attribute(:shipwire_id, shipwire_id)
        end

        it 'will post to shipwire' do
          expect(customer_return).to receive(:process_shipwire_return!).and_call_original
          customer_return.save!
          expect(customer_return.shipwire_id).not_to be nil
        end
      end
    end
  end
end

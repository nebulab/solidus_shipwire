RSpec.describe Spree::ShipwireWebhooks::StockController, type: :controller do
  stub_signature!

  controller Spree::ShipwireWebhooks::StockController do
  end

  let(:stock_item) { create(:stock_item) }
  let(:variant) { stock_item.variant }
  let(:stock_location) { stock_item.stock_location }
  let(:delta) { 13 }

  let(:stock_params) do
    {
      'body' => {
        'orderId'                       => '1111',
        'productId'                     => variant.shipwire_id,
        'warehouseId'                   => stock_location.shipwire_id,
        'fromState'                     => 'pending',
        'toState'                       => 'good',
        'delta'                         => delta,
        'toStateStockAfterTransition'   => 23,
        'fromStateStockAfterTransition' => 10
      }
    }
  end

  before do
    variant.update_attribute(:shipwire_id, '1234')
    stock_location.update_attribute(:shipwire_id, '5678')
  end

  subject do
    @request.headers['RAW_POST_DATA'] = stock_params.to_json
    @request.headers['Content-Type'] = 'application/json'
    post :create, params: stock_params
  end

  context 'when receive stock webhook' do
    it 'Add a StockMovement' do
      expect { subject }.to change(Spree::StockMovement, :count).by(1)
      expect(Spree::StockMovement.last.quantity).to eq delta
    end

    it 'change' do
      expect { subject }.to change { stock_item.reload.count_on_hand }.by(13)
    end
  end
end

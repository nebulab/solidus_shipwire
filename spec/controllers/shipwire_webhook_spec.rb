RSpec.describe Spree::ShipwireWebhookController, type: :controller do
  controller Spree::ShipwireWebhookController do
    def create
      render json: {}, status: :no_content
    end
  end

  let(:shipwire_params) { { key: :value } }

  let(:headers) do
    signature_hash(shipwire_params)
  end

  context 'when receive shipwire information' do
    let(:order) { create(:order) }

    before do
      @request.headers.merge! headers

      if Rails.version >= '5.0'
        @request.headers['Content-Type'] = 'application/json'
        post :create, params: shipwire_params
      else
        post :create, shipwire_params.to_json, format: :json
      end
    end

    context 'without valid signature' do
      let(:headers) { {} }

      it 'return unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'have valid signature' do
      expect(response).to have_http_status(:no_content)
    end
  end
end

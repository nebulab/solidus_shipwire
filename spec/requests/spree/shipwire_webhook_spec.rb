RSpec.describe 'Inherited Controller subscribe to shipwire', type: :request do
  context 'head requests' do
    it 'return head :ok if path exists' do
      head '/shipwire_webhooks/stock'
      expect(response).to have_http_status(:ok)
    end

    it 'return head :not_found if path not exists' do
      head '/shipwire_webhooks/not_present'
      expect(response).to have_http_status(:not_found)
    end
  end
end

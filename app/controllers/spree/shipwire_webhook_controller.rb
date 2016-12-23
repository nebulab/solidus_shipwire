module Spree
  class ShipwireWebhookController < ActionController::Base
    respond_to :json

    before_action :validate_key, except: :subscribe

    def subscribe
      if exists_in_post?("/shipwire_webhooks/#{params[:path]}")
        head :ok
      else
        head :not_found
      end
    end

    private

    def exists_in_post?(path)
      Spree::Core::Engine.routes.recognize_path(path, method: :post)
      true
    rescue ActionController::RoutingError
      false
    end

    def validate_key
      render json: { result: :unauthorized }, status: :unauthorized unless valid_shipwire_token?
    end

    def valid_shipwire_token?
      request.headers['HTTP_X_SHIPWIRE_SIGNATURE'] == calculated_hmac
    end

    def calculated_hmac
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('SHA256'),
        Spree::ShipwireConfig.secret,
        request.raw_post
      )
    end
  end
end

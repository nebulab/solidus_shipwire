module ShipwireHacks
  module StubbingHelpers
    def stub_signature!
      before do
        allow(controller).to receive(:validate_key).and_return true
      end
    end
  end

  module SignatureHelpers
    def signature_hash(params)
      { 'X-Shipwire-Signature' => "#{signature(params.to_json)};secret=1" }
    end

    private

    def signature(data)
      OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        [Spree::ShipwireConfig.secret].pack('H*'),
        data
      )
    end
  end
end

RSpec.configure do |config|
  config.extend  ShipwireHacks::StubbingHelpers,  type: :controller
  config.include ShipwireHacks::SignatureHelpers, type: :controller
end

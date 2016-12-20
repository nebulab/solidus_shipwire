module ShipwireHacks
  def signature_hash(params)
    { 'X-Shipwire-Signature' => signature(params.to_json) }
  end

  private

  def signature(data)
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest.new('sha256'),
        Spree::SolidusShipwireConfig.secret,
        data
      )
    ).strip
  end
end

RSpec.configure do |config|
  config.include ShipwireHacks, type: :controller
end

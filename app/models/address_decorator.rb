module SolidusShipwire
  module AddressDecorator
    def self.prepended(base)
      base.acts_as_shipwireable serializer: SolidusShipwire::AddressSerializer
    end

    Spree::Address.prepend self
  end
end

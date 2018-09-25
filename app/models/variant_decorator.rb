module SolidusShipwire
  module VariantDecorator
    def self.prepended(base)
      base.acts_as_shipwireable api_class: Shipwire::Products,
                                serializer: SolidusShipwire::VariantSerializer
    end

    Spree::Variant.prepend self
  end
end

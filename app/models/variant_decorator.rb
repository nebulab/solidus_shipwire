module SolidusShipwire
  module VariantDecorator
    def self.prepended(base)
      base.acts_as_shipwireable api_class: Shipwire::Products,
                                serializer: SolidusShipwire::VariantSerializer
    end

    def update_stocks_from_shipwire
      Shipwire::Stock.new.list( sku: self.sku)
    end

    Spree::Variant.prepend self
  end
end

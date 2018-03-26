module SolidusShipwire
  module ShippingManifest
    class ManifestItemSerializer < ActiveModel::Serializer
      attributes :quantity

      attribute(:sku)                            { object.variant.sku }
      attribute(:commercialInvoiceValue)         { object.line_item.price }
      attribute(:commercialInvoiceValueCurrency) { "USD" }
    end
  end
end

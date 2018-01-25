module SolidusShipwire
  module ManifestItem
    def to_shipwire
      {
        sku: variant.sku,
        quantity: quantity,
        commercialInvoiceValue: line_item.price,
        commercialInvoiceValueCurrency: 'USD'
      }
    end
  end
end

Spree::ShippingManifest::ManifestItem.prepend SolidusShipwire::ManifestItem

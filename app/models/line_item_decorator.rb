module SolidusShipwire::LineItem
  def to_shipwire
    {
      sku: sku,
      quantity: quantity,
      commercialInvoiceValue: price,
      commercialInvoiceValueCurrency: 'USD'
    }
  end
end

Spree::LineItem.prepend SolidusShipwire::LineItem

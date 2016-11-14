module SolidusShipwire::LineItem
  def self.prepended(base)
    base.scope :on_shipwire, -> { base.joins(:variant).where.not(spree_variants: { shipwire_id: nil })  }
  end

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

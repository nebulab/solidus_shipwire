module SolidusShipwire
  module InventoryUnit
    def self.prepended(base)
      base.scope :eligible_for_shipwire, -> { base.joins(:variant).where.not(spree_variants: { shipwire_id: nil }) }
    end
  end
end

Spree::InventoryUnit.prepend SolidusShipwire::InventoryUnit

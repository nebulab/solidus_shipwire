module SolidusShipwire::Order
  prepend SolidusShipwire::Proxy

  def self.prepended(base)
    #base.after_save :update_on_shipwire
    base.state_machine.after_transition to: :complete, do: :in_shipwire, if: :line_items_in_shipwire?
  end

  def to_shipwire
    {
      orderId: id,
      orderNo: number,
      options: {
        currency: shipwire_currency,
        canSplit: shipwire_can_split?,
        hold: shipwire_hold?,
        server: shipwire_server,
      },
      items: line_items_in_shipwire,
      shipTo: ship_address.to_shipwire.merge(email: email)
    }
  end

  def line_items_in_shipwire?
    line_items_in_shipwire.any?
  end

  def line_items_in_shipwire
    line_items.on_shipwire.map(&:to_shipwire)
  end

  def to_shipwire_object(hash)
    SolidusShipwire::ShipwireObjects::Order.new(hash['id'], self, hash)
  end

  def shipwire_can_split?
    1
  end

  def shipwire_hold?
    0
  end

  def shipwire_currency
    'USD'
  end

  def shipwire_server
    'Production'
  end

  private

  def shipwire_instance
    Shipwire::Orders.new
  end
end

Spree::Order.prepend SolidusShipwire::Order

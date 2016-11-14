module SolidusShipwire::Order
  prepend SolidusShipwire::Proxy

  def self.prepended(base)
    base.state_machine.after_transition to: :complete, do: :in_shipwire, if: :line_items_in_shipwire?
  end

  def to_shipwire
    {
      orderId: id,
      orderNo: number,
      options: {
        currency: 'USD',
        canSplit: 1,
        hold: 1,
        server: 'Production'
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

  def create_on_shipwire(obj)
    response = Shipwire::Orders.new.create(obj)
    raise response.error_report unless response.ok?
    update_column(:shipwire_id, response.body['resource']['items'].first['resource']['id'])
    find_on_shipwire(response.body['resource']['items'].first['resource']['id'])
  end

  def find_on_shipwire(shipwire_id)
    Shipwire::Orders.new.find shipwire_id
  end

  def to_shipwire_object(hash)
    ShipwireObject.new(hash['id'], self, hash)
  end
end

Spree::Order.prepend SolidusShipwire::Order

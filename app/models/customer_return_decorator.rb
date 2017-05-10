module SolidusShipwire::CustomerReturn
  prepend SolidusShipwire::Proxy

  def self.prepended(base)
    base.after_save :process_shipwire_return!, if: :create_on_shipwire?
  end

  def to_shipwire
    {
      externalId: order.number,
      originalOrder: {
        id: order.shipwire_id.to_s
      },
      items:
        shipwire_line_items.map { |s, q| { sku: s, quantity: q } },
      options: {
        generatePrepaidLabel: generate_prepaid_label,
        emailCustomer: email_customer,
        warehouseId: warehouse_id,
        warehouseExternalId: warehouse_external_id,
        warehouseRegion: warehouse_region
      }
    }
  end

  private

  def create_on_shipwire?
    shipwire_order.present?
  end

  def process_shipwire_return!
  create_on_shipwire
  rescue SolidusShipwire::ResponseException => e
    if e.response.validation_errors
      errors.add(:shipwire, "Shipwire: #{e.response.validation_errors.first['message']}")
    end
  end

  def to_shipwire_object(hash)
    SolidusShipwire::ShipwireObjects::Return.new(hash['id'], self, hash)
  end

  def shipwire_line_items
    return_items.each_with_object(Hash.new(0)) do |item, hash|
      hash[item.inventory_unit.variant.sku] += 1
    end
  end

  def generate_prepaid_label
    1
  end

  def email_customer
    1
  end

  def warehouse_id
    shipwire_order[:resource][:options][:resource][:warehouseId]
  end

  def warehouse_external_id
    nil
  end

  def warehouse_region
    ''
  end

  def shipwire_order
    return @shipwire_order if defined? @shipwire_order
    @shipwire_order = begin
      response = order.find_on_shipwire(order.shipwire_id)
      response.ok? ? response.body.with_indifferent_access : nil
    end
  end

  def shipwire_instance
    Shipwire::Returns.new
  end
end

Spree::CustomerReturn.prepend SolidusShipwire::CustomerReturn

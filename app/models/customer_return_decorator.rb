module SolidusShipwire
  module CustomerReturn
    prepend SolidusShipwire::Proxy

    def self.prepended(base)
      base.after_save :process_shipwire_return!, if: :create_on_shipwire?
    end

    def to_shipwire
      {
        originalOrder: {
          id: order.shipwire_id
        },
        items:
          shipwire_return_items.map { |s, q| { sku: s, quantity: q } },
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
      if e.response.has_error_summary?
        if e.response.error_summary.include?("Something went wrong")
          errors.add(:shipwire_something_went_wrong, e.response.error_summary)
        else
          errors.add(error_keys.key(e.response.error_summary), e.response.error_summary)
        end
      elsif e.response.has_validation_errors?
        e.response.validation_errors.each do |error|
          errors.add(error_keys.key(error['message']), error['message'])
        end
      end
    end

    def error_keys
      {
        shipwire_unprocessed:          "Only orders that are \"processed\" and not \"cancelled\" can be returned",
        shipwire_already_reported:     "You have already reported this issue.",
        shipwire_connection_failed:    "Unable to connect to Shipwire",
        shipwire_timeout:              "Shipwire connection timeout",
        shipwire_something_went_wrong: "Something went wrong"
      }
    end

    def to_shipwire_object(hash)
      SolidusShipwire::ShipwireObjects::Return.new(hash['id'], self, hash)
    end

    def shipwire_return_items
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
end

Spree::CustomerReturn.prepend SolidusShipwire::CustomerReturn

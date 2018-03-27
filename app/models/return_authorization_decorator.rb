module SolidusShipwire
  module ReturnAuthorizationDecorator
    # Return authorization on shipwire should be splitted by order on shipwire
    # If a return authorization contains inventory units related to different
    # order on shipwire, it should be splitter in more than one return
    # authorization, one for each of them.
    def self.prepended(base)
      base.acts_as_shipwireable api_class: Shipwire::Returns,
                                serializer: SolidusShipwire::ReturnAuthorizationSerializer

      # At the moment the creation on shipwire has been removed, because the old
      # logic doesn't consider that an return authorization can be splitter in
      # more than one.
      #
      # base.after_validation :process_shipwire_return!, if: :create_on_shipwire?
    end

    private

    # before create in inventory units are eligible for shipwire split them by
    # shipment and create a ReturnAuthorization for every shipwire shipment.
    # before_create do
    #   inventory_units.eligible_for_shipwire.group_by(:shipment).each do |shipment, inventory_units|
    #     Spree::ReturnAuthorization.create(...)
    #   end
    # rescue SolidusShipwire::ResponseException => e
    #   shipwire_errors = Shipwire::ReturnError.build_from_response(e.response)
    #   shipwire_errors.each { |error| errors.add(error.key, error.message) }
    # end

    # def create_on_shipwire?
    #   order.shipped? && shipwire_order.present?
    # end

    # def shipwire_order
    #   return @shipwire_order if defined? @shipwire_order
    #   @shipwire_order = begin
    #     return nil if order.nil? || order.shipwire_id.nil?

    #     response = order.find_on_shipwire(order.shipwire_id)
    #     response.ok? ? response.body.with_indifferent_access : nil
    #   end
    # end

    Spree::ReturnAuthorization.prepend self
  end
end

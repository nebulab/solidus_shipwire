module SolidusShipwire
  module ShipwireCustomerReturnsController
    def self.prepended(base)
      base.after_action :shipwire, only: [:create]
    end

    private

    def shipwire
      if @customer_return.errors.messages[:shipwire]
        flash[:error] = @customer_return.errors.messages[:shipwire]
      end
    end
  end
end

Spree::Admin::CustomerReturnsController.prepend SolidusShipwire::ShipwireCustomerReturnsController

module SolidusShipwire
  module ShipwireCustomerReturnsController
    def self.prepended(base)
      base.after_action :flash_message, only: [:create]
    end

    private

    def flash_message
      message = @customer_return.errors.messages[:shipwire]
      return unless message
      flash[:error] = message
    end
  end
end

Spree::Admin::CustomerReturnsController.prepend SolidusShipwire::ShipwireCustomerReturnsController

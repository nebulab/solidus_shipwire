module SolidusShipwire
  module ShipwireReturnAuthorizationsController
    def self.prepended(base)
      base.after_action :flash_message, only: [:create]
    end

    private

    def flash_message
      message = @return_authorization.errors.messages[:shipwire]
      return unless message
      flash[:error] = message
    end
  end
end

Spree::Admin::ReturnAuthorizationsController.prepend SolidusShipwire::ShipwireReturnAuthorizationsController

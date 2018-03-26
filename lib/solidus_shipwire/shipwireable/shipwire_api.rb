module SolidusShipwire
  module Shipwireable
    module ShipwireApi
      def self.included(base)
        base.extend SolidusShipwire::Shipwireable::ShipwireApi::ClassMethods
        base.initialize_acts_as_shipwireable_on_shipwire_api
      end

      module ClassMethods
        def initialize_acts_as_shipwireable_on_shipwire_api
          configure_shipwire_api_class if shipwireable_config[:api_class].present?
        end

        def acts_as_shipwireable_on(*args)
          super(*args)
          initialize_acts_as_shipwireable_on_shipwire_api
        end

        private

        def configure_shipwire_api_class
          shipwire_api_class = shipwireable_config[:api_class]

          if shipwire_api_class.nil? || !shipwire_api_class.ancestors.include?(Shipwire::Api)
            raise ArgumentError, "shipwire_api_class is not set or doesn't inherit from Shipwire::Api"
          end

          @shipwire_api = shipwire_api_class.new

          # This include some helpful methods to call shipwire API.
          # For example Spree::Variant.first.create_on_shipwire takes a variant
          # converts it in a shipwire json format and sends it shipwire.
          include ShipwireApiMethods
        end
      end

      module ShipwireApiMethods
        def self.included(base)
          base.extend ClassMethods
        end

        # This module adds a class method to the object to call shipwire api
        # methods.
        # For example Spree::Variant.find_on_shipwire(shipwire_id) uses
        # @shipwire_api object to call a find on shipwire object
        module ClassMethods
          def shipwire_api
            @shipwire_api
          end

          def find_on_shipwire(shipwire_id)
            shipwire_api.find(shipwire_id)
          end

          def update_on_shipwire(shipwire_id, shipwire_json)
            shipwire_api.update(shipwire_id, shipwire_json)
          end

          def create_on_shipwire(shipwire_json)
            shipwire_api.create(shipwire_json)
          end
        end
      end
    end
  end
end

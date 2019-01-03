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

          def respond_to_missing?(method_name, include_private = false)
            (method_name == :cancel_from_shipwire && shipwire_api.respond_to?(:cancel)) || super
          end

          def method_missing(method_name, *arguments, &block)
            if method_name == :cancel_from_shipwire
              shipwire_api.cancel(*arguments)
            else
              super
            end
          end
        end

        def find_on_shipwire
          response = self.class.find_on_shipwire(shipwire_id)

          raise SolidusShipwire::ResponseException.new(response), response.error_report unless response.ok?
          response
        end

        def update_on_shipwire
          raise "shipwire id is nil" if shipwire_id.nil?

          self.class.update_on_shipwire(shipwire_id, to_shipwire_json)
        end

        def update_on_shipwire!
          response = update_on_shipwire

          raise SolidusShipwire::ResponseException.new(response), response.error_report unless response.ok?
          response
        end

        def create_on_shipwire
          response = self.class.create_on_shipwire(to_shipwire_json)
          if response.ok?
            shipwire_id = response.resource[:items].first[:resource][:id]
            update_shipwire_id(shipwire_id)
          end
          response
        end

        def create_on_shipwire!
          response = create_on_shipwire

          raise SolidusShipwire::ResponseException.new(response), response.error_report unless response.ok?
          response
        end

        def find_or_create_on_shipwire
          if shipwire_id.present?
            find_on_shipwire
          else
            create_on_shipwire
          end
        end

        def find_or_create_on_shipwire!
          if shipwire_id.present?
            find_on_shipwire
          else
            create_on_shipwire!
          end
        end

        def update_shipwire_id(shipwire_id)
          if persisted?
            update_column(:shipwire_id, shipwire_id)
          else
            self.shipwire_id = shipwire_id
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          (method_name == :cancel_from_shipwire && self.class.shipwire_api.respond_to?(:cancel)) || super
        end

        def method_missing(method_name, *arguments, &block)
          return super if method_name != :cancel_from_shipwire

          return if shipwire_id.blank?

          response = self.class.cancel_from_shipwire(shipwire_id)
          update_attribute(:shipwire_id, nil)

          response
        end
      end
    end
  end
end

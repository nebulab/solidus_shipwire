module SolidusShipwire
  module Shipwireable
    module ShipwireSerializer
      def self.included(base)
        base.extend SolidusShipwire::Shipwireable::ShipwireSerializer::ClassMethods
        base.initialize_acts_as_shipwireable_on_shipwire_serializer
      end

      module ClassMethods
        def initialize_acts_as_shipwireable_on_shipwire_serializer
          configure_shipwire_serializer if shipwireable_config[:serializer].present?
        end

        def acts_as_shipwireable_on(*args)
          super(*args)
          initialize_acts_as_shipwireable_on_shipwire_serializer
        end

        private

        def configure_shipwire_serializer
          shipwire_serializer = shipwireable_config[:serializer]

          if shipwire_serializer.nil? || !shipwire_serializer.ancestors.include?(ActiveModel::Serializer)
            raise ArgumentError, "shipwire_serializer is not set or doesn't implement from ActiveModel::Serializer"
          end

          @shipwire_serializer = shipwire_serializer

          # This include some helpful methods to serialize the object.
          include ShipwireSerializerMethods
        end
      end

      module ShipwireSerializerMethods
        def self.included(base)
          base.extend ClassMethods
        end

        # This module adds a class method to the object to call shipwire
        # serializer methods.
        # For example Spree::Variant.shipwire_serializer returns a serializer
        # that convert the object in a shipwire json
        module ClassMethods
          def shipwire_serializer
            @shipwire_serializer
          end
        end

        def to_shipwire_json
          self.class.shipwire_serializer.new(self).as_json
        end
      end
    end
  end
end

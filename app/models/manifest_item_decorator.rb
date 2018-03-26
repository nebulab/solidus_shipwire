module SolidusShipwire
  module ManifestItem
    def self.prepended(base)
      base.include ActiveModel::Serialization
      base.extend SolidusShipwire::Shipwireable
      base.acts_as_shipwireable serializer: SolidusShipwire::ShippingManifest::ManifestItemSerializer
    end

    Spree::ShippingManifest::ManifestItem.prepend self
  end
end

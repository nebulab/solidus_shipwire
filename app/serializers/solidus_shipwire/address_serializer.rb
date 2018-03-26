module SolidusShipwire
  class AddressSerializer < ActiveModel::Serializer
    attributes :company, :address1, :address2, :city, :phone

    attribute :state_name, key: :state
    attribute :zipcode,    key: :postalCode

    attribute(:name)    { "#{object.firstname} #{object.lastname}" }
    attribute(:country) { object.country.iso }
  end
end

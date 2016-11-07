module SolidusShipwire::AddressDecorator
  def to_shipwire
    {
      # Recipient details
      name: "#{firstname} #{lastname}",
      company: company,
      address1: address1,
      address2: address2,
      city: city,
      state: state_name,
      postalCode: zipcode,
      country: country.iso
    }
  end
end

Spree::Address.prepend SolidusShipwire::AddressDecorator

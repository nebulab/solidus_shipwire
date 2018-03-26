require 'spec_helper'

describe SolidusShipwire::AddressSerializer do
  context "#as_json" do
    let!(:address) { create(:address) }

    subject { SolidusShipwire::AddressSerializer.new(address).as_json(include: '**') }

    it "is formatted as shipwire json" do
      is_expected.to include(
        name: "#{address.firstname} #{address.lastname}",
        company: address.company,
        address1: address.address1,
        address2: address.address2,
        city: address.city,
        state: address.state_name,
        postalCode: address.zipcode,
        country: address.country.iso,
        phone: address.phone
      )
    end
  end
end

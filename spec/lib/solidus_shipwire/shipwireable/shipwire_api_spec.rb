class FakeShipwireApi < Shipwire::Api
  def find; end

  def update; end

  def create; end
end

class DummyClass
  include ActiveModel::Model
  extend SolidusShipwire::Shipwireable

  acts_as_shipwireable api_class: FakeShipwireApi

  def shipwire_id; end

  def shipwire_id=(param); end
end

describe SolidusShipwire::Shipwireable::ShipwireApi do
  context "when api_class is configured" do
    describe DummyClass do
      it_behaves_like "shipwireable api class"
      it_behaves_like "shipwireable api instance"
    end
  end
end

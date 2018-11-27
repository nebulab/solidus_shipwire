class FakeShipwireApi < Shipwire::Api
  def find; end

  def update; end

  def create; end
end

class DummyClass
  include ActiveModel::Model
  extend SolidusShipwire::Shipwireable

  acts_as_shipwireable api_class: FakeShipwireApi

  attr_accessor :shipwire_id
end

describe SolidusShipwire::Shipwireable::ShipwireApi do
  context "when api_class is configured" do
    describe DummyClass do
      it_behaves_like "shipwireable api class"
      it_behaves_like "shipwireable api instance"
    end

    describe ".cancel_from_shipwire" do
      context "when the shipwire api class defines cancel method" do
        before do
          allow_any_instance_of(FakeShipwireApi)
            .to receive(:respond_to?)
            .with(:cancel)
            .and_return(true)
        end

        it "is defined" do
          expect(DummyClass).to respond_to(:cancel_from_shipwire)
        end

        let(:shipwire_id) { '1234567' }

        it "calls the cancel action from shipwire api class" do
          expect_any_instance_of(FakeShipwireApi)
            .to receive(:cancel)
            .with(shipwire_id)

          DummyClass.cancel_from_shipwire(shipwire_id)
        end
      end

      context "when the shipwire api class doesn't define cancel method" do
        it "isn't defined" do
          expect(DummyClass).not_to respond_to(:cancel_from_shipwire)
        end
      end
    end

    describe "#cancel_from_shipwire" do
      let(:dummy_instance) { DummyClass.new(shipwire_id: shipwire_id) }
      let(:shipwire_id) { '1234567' }

      context "when the shipwire api class defines cancel method" do
        before do
          allow_any_instance_of(FakeShipwireApi)
            .to receive(:respond_to?)
            .with(:cancel)
            .and_return(true)
        end

        context "and the shipwire id is present" do
          let(:response) { double(:response, ok?: true) }

          it "calls the class method" do
            expect(dummy_instance).to respond_to(:cancel_from_shipwire)

            expect(dummy_instance)
              .to receive(:update_attribute)
              .with(:shipwire_id, nil)
              .and_return(true)

            expect(DummyClass)
              .to receive(:cancel_from_shipwire)
              .with(shipwire_id)
              .and_return(response)

            expect(dummy_instance.cancel_from_shipwire).to eq(response)
          end
        end

        context "and the shipwire id is nil" do
          let(:shipwire_id) { nil }
          it "returns false" do
            expect(DummyClass).not_to receive(:cancel_from_shipwire)

            expect(dummy_instance.cancel_from_shipwire).to be_nil
          end
        end
      end

      context "when the shipwire api class doesn't define cancel method" do
        it "isn't defined" do
          expect(dummy_instance).not_to respond_to(:cancel_from_shipwire)
        end
      end
    end
  end
end

FactoryBot.modify do
  factory :completed_order_with_totals do
    trait :pending_on_shipwire do
      after(:create, &:in_shipwire)
    end

    trait :shipped_on_shipwire do
      after(:create) do |order|
        shipwire = order.in_shipwire

        Shipwire::Orders.new.holds_clear(shipwire.attrs[:id]) while order.in_shipwire.attrs[:status] == 'held'

        Shipwire::Orders.new.mark_processed(shipwire.attrs[:id])
        Shipwire::Orders.new.mark_complete(shipwire.attrs[:id])
      end
    end
  end
end

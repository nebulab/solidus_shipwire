class AddShipwireIdToCustomerReturn < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_customer_returns, :shipwire_id, :integer, default: nil, null: true
  end
end

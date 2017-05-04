class AddShipwireIdToCustomerReturn < ActiveRecord::Migration
  def change
    add_column :spree_customer_returns, :shipwire_id, :integer, default: nil, null: true
  end
end

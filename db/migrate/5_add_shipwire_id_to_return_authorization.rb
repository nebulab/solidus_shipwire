class AddShipwireIdToReturnAuthorization < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_return_authorizations, :shipwire_id, :integer, default: nil, null: true
  end
end

class AddShipwireIdToOrder < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_orders, :shipwire_id, :integer, default: nil, null: true
  end
end

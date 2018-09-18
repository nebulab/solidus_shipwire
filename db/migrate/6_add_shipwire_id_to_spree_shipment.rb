class AddShipwireIdToSpreeShipment < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_shipments, :shipwire_id, :integer
  end
end

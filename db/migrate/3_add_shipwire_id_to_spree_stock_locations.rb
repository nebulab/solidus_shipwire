class AddShipwireIdToSpreeStockLocations < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_stock_locations, :shipwire_id, :string
  end
end

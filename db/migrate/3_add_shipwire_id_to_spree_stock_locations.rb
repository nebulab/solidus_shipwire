class AddShipwireIdToSpreeStockLocations < ActiveRecord::Migration
  def change
    add_column :spree_stock_locations, :shipwire_id, :string
  end
end

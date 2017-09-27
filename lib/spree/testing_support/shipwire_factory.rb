require 'retriable'

require_relative 'shipwire_factory/product'
require_relative 'shipwire_factory/warehouse'

module ShipwireFactory
  class MissingOnShipwire < StandardError; end
  class CreationErrorOnShipwire < StandardError; end

  def sw_product_factory
    ShipwireFactory::Product.new
  end

  def sw_warehouse_factory
    ShipwireFactory::Warehouse.new
  end
end

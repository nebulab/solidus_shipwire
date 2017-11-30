module ShipwireFactory
  class Product
    def create_product_in_stock(params)
      product_json = default_product_json.merge params

      shipwire_product = Shipwire::Products.new.create(product_json)
      raise CreationErrorOnShipwire, shipwire_product.error_report unless shipwire_product.ok?

      shipwire_product
    end

    def in_stock(params = {})
      search_params = { sku: 'product-in-stock', classification: 'baseProduct',
                        limit: 1 }.merge params

      Retriable.retriable on: { MissingOnShipwire => nil },
                          on_retry: proc{ create_product_in_stock(search_params) } do

        shipwire_response = Shipwire::Products.new.list(search_params)

        products = shipwire_response.body['resource']['items']

        raise MissingOnShipwire if products.empty?

        Shipwire::Stock.new.adjust(
          sku: products.first['resource']['sku'],
          quantity: 50,
          warehouseId: warehouse['id'],
          reason: 'Init for test'
        )

        products.first['resource']
      end
    end

    private

    def default_product_json
      {
        sku: "test-sku",
        classification: 'baseProduct',
        description: 'description',
        countryOfOrigin: "US",
        category: "FURNITURE_&_APPLIANCES",
        batteryConfiguration: 'NOBATTERY',
        values: {
          costValue: 10,
          retailValue: 10,
          costCurrency: "USD",
          retailCurrency: "USD"
        },
        dimensions: {
          length: 1,
          width: 10,
          height: 1,
          weight: 1
        }
      }
    end

    def warehouse
      ShipwireFactory::Warehouse.new.default
    end
  end
end

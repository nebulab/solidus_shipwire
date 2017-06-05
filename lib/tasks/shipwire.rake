namespace :solidus_shipwire do
  desc 'Sync solidus variants in shipwire'
  task sync_variants: :environment do
    Spree::Variant.all.each(&:in_shipwire)
  end

  task link_shipwire_product: :environment do
    sku_id_hashmap = {}
    page = 0

    loop do
      limit = 20
      params ||= { limit: limit }
      params[:offset] = limit * page

      shipwire_response = Shipwire::Products.new.list(params)

      sku_id_hashmap.merge! shipwire_response.to_sku_id_hashmap

      page += 1
      break unless shipwire_response.next?
    end

    sku_id_hashmap.map do |sku, shipwire_id|
      update_shipwire_id(sku, shipwire_id)
    end

    stock_massive_sync

    print_results(results)
  end

  task stock_massive_sync: :environment do
    stock_massive_sync
  end

  task prepare_orders_for_customer_return_spec: :environment do
    email = 'spree@example.com'
    variant_skus_filepath = "#{Rails.root}/spec/fixtures/files/shipwire_variant_skus.yml"
    orders_filepath = "#{Rails.root}/spec/fixtures/files/shipwire_order_ids.yml"

    unless File.exist?(File.dirname(orders_filepath))
      FileUtils.mkdir_p(File.dirname(orders_filepath))
    end

    variant_skus = YAML.load_file(variant_skus_filepath)

    sku_variant_1 = variant_skus['sku_1']
    sku_variant_2 = variant_skus['sku_2']

    orders = []

    orders_line_items = [
      [ { sku: sku_variant_1, quantity: '1'} ],
      [ { sku: sku_variant_1, quantity: '1'} ],
      [
        { sku: sku_variant_1, quantity: '2' },
        { sku: sku_variant_2, quantity: '2' }
      ],
      [ { sku: sku_variant_2, quantity: '1'} ]
    ]

    orders_line_items.each do |line_items|
      order = Spree::Order.create!(email: email, store: Spree::Store.first)

      line_items.each do |line_item|
        variant = Spree::Variant.find_by_sku(line_item[:sku])
        order.contents.add(variant, line_item[:quantity])
      end

      order.reload
      order.next!

      #address
      order.bill_address = Spree::Address.first
      order.ship_address = Spree::Address.first
      order.next!

      #delivery

      order.next!

      #payment
      credit_card = Spree::CreditCard.new(
        verification_value: 123,
        month: 12,
        year: 1.year.from_now.year,
        number: '4111111111111111',
        name: 'Spree Commerce',
        payment_method: Spree::PaymentMethod.find_by_name("Credit Card"),
        address: Spree::Address.first
      )
      order.payments.create!(payment_method: credit_card.payment_method, amount: order.total, source: credit_card)
      order.payment_state = 'paid'
      order.next!

      #confirm
      order.complete!

      orders << order
    end

    shipwire_base_url = "https://merchant.beta.shipwire.com/merchants/ship/confirm/orderId/"
    shipwire_ids = {}
    puts "----------------------------------------------------------------------------"
    order = orders[0]
    shipwire_ids['pending_order'] = order.shipwire_id
    puts "Order number #{order.number} created! State: #{order.state}, shipwire_id: #{order.shipwire_id}\n\n"

    order = orders[1]
    shipwire_ids['shipped_order_single_return_item'] = order.shipwire_id
    puts "Order number #{order.number} created! State: #{order.state}, shipwire_id: #{order.shipwire_id}"
    puts "CMD/CRTL Click the following link and mark this order as shipped #{shipwire_base_url}#{order.shipwire_id}\n\n"

    order = orders[2]
    shipwire_ids['shipped_order_multiple_return_items'] = order.shipwire_id
    puts "Order number #{order.number} created! State: #{order.state}, shipwire_id: #{order.shipwire_id}"
    puts "CMD/CRTL Click the following link and mark this order as shipped #{shipwire_base_url}#{order.shipwire_id}\n\n"

    order = orders[3]
    shipwire_ids['already_returned_order'] = order.shipwire_id
    puts "Order number #{order.number} created! State: #{order.state}, shipwire_id: #{order.shipwire_id}"
    puts "CMD/CRTL Click the following link and mark this order as shipped #{shipwire_base_url}#{order.shipwire_id}"
    puts "N.B.: The test for this order, identified by customer_return_entity_exist vcr, should run twice."
    puts "The first time it will fail but will have the effect to post a return for this order."
    puts "Then delete customer_return_entity_exist vcr and run the test a second time."
    puts "----------------------------------------------------------------------------\n"
    puts "All the shipwire ids were saved to #{orders_filepath}."
    puts "You should now copy this file inside the gem spec/fixtures/files/"
    puts "shipwire_order_ids.yml is used as source for customer_return spec along with shipwire_variant_skus.yml"
    puts "shipwire_variant_skus.yml must contain two valid variant skus in sync with beta.shipwire environment and enough stock quantities."
    puts "You can now delete all the customer_return* cassettes and regenerate them by running tests."

    File.open(orders_filepath, 'w') {|f| f.write shipwire_ids.to_yaml }
  end

  private

  def stock_massive_sync(shipwire_ids = nil)
    page = 0

    loop do
      limit = 20
      params ||= { limit: limit }
      params[:offset] = limit * page
      params[:productId] = shipwire_ids unless shipwire_ids.nil?
      stocks_response = Shipwire::Stock.new.list(params)

      stocks_response.body['resource']['items'].each do |shipwire_stock|
        stock_item = Spree::StockItem.joins(:variant, :stock_location).find_by(
          spree_variants: {
            shipwire_id: shipwire_stock['resource']['productId']
          }, spree_stock_locations: {
            shipwire_id: shipwire_stock['resource']['warehouseId']
          }
        )

        next if stock_item.nil?

        results[:update_stock][stock_item.variant.sku] = shipwire_stock['resource']['good']
        stock_item.update_attribute(:count_on_hand, shipwire_stock['resource']['good'])
      end

      page += 1
      break unless stocks_response.next?
    end
  end

  def results
    @results ||= {
      updated:      {},
      skipped:      {},
      update_stock: {},
      not_found:    {}
    }
  end

  def update_shipwire_id(sku, shipwire_id)
    variant = Spree::Variant.find_by_sku(sku)

    if variant.present?
      update_shipwire_id_variant(variant, shipwire_id)
    else
      results[:not_found][sku] = 'not found'
    end
  end

  def update_shipwire_id_variant(variant, shipwire_id)
    if variant.shipwire_id.nil?
      variant.update_attribute(:shipwire_id, shipwire_id)
      results[:updated][variant.sku] = 'ok'
    elsif variant.shipwire_id != shipwire_id
      results[:skipped][variant.sku] = 'already linked'
    else
      results[:skipped][variant.sku] = 'same'
    end
  end

  def print_results(results)
    results.each do |k, v|
      puts k
      puts v
    end
  end
end

module SolidusShipwire
  class MoveShipwireIdToShipment
    def process
      query = <<-SQL
        UPDATE spree_shipments AS S
          SET shipwire_id = O.shipwire_id
        FROM spree_orders AS O
        WHERE S.order_id = O.id
        AND O.shipwire_id IS NOT NULL
      SQL

      ActiveRecord::Base.connection.execute(query)
    end
  end
end

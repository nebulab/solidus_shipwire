require 'solidus_shipwire/move_shipwire_id_to_shipment'

namespace :solidus_shipwire do
  desc "Move the shipwire_id from the order the the first related shipment"
  task move_shipwire_id_to_shipment: :environment do
    result = SolidusShipwire::MoveShipwireIdToShipment.new.process

    puts "Updated:"
    puts "ntuples: #{result.ntuples}"
    puts "nfields: #{result.nfields}"
    puts "cmd_tuples: #{result.cmd_tuples}"
  end
end

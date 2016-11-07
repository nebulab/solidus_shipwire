namespace :solidus_shipwire do
  desc "Sync solidus variants in shipwire"
  task :sync_variants => :environment do
    Spree::Variant.all.each do |variant|
      variant.in_shipwire
    end
  end
end

require "caboose-store/version"

namespace :caboose_store do
  desc "Initializes the database for a caboose installation"
  task :db => :environment do
    CabooseStore::Schema.create_schema
    CabooseStore::Schema.load_data
  end
  
  desc "Verifies all tables and columns are created."
  task :create_schema => :environment do CabooseStore::Schema.create_schema end
  
  desc "Loads data into caboose tables"
  task :load_data => :environment do CabooseStore::Schema.load_data end
  
  desc "Fix variant sort order"
  task :set_variant_sort_order => :environment do
    CabooseStore::Product.all.each do |p|
      puts "Setting sort order for product #{p.id}..."
      i = 1
      CabooseStore::Variant.where(:product_id => p.id).reorder(:id).all.each do |v|
        v.update_attribute('sort_order', i)
        i = i + 1
      end
    end
  end
end

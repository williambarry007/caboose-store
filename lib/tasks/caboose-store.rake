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

end

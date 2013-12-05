
module CabooseStore
  class Vendor < ActiveRecord::Base
    self.table_name = "store_vendors"  
    attr_accessible :id, :name  
  end
end

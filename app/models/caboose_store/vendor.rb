
module CabooseStore
  class Vendor < ActiveRecord::Base
    self.table_name = "store_vendors"  
    attr_accessible :id, :name, :status
    has_many :products
    # after_save :update_products
    after_save :clear_filters
    
    def update_products
      self.products.each { |product| product.update_attribute(:vendor_status, self.status) }
    end
    
    def clear_filters
      SearchFilter.delete_all
    end
  end
end

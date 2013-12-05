
module CabooseStore
  class ProductImageVariant < ActiveRecord::Base
    self.table_name = "store_product_image_variants"
    
    belongs_to :product_image
    belongs_to :variant
          
  end
end

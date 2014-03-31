
module CabooseStore
  class Variant < ActiveRecord::Base
    self.table_name = "store_variants"
    
    belongs_to :product
    has_many :product_image_variants
    has_many :product_images, :through => :product_image_variants    
    
    attr_accessible :id,      # Variant’s unique id.
      :product_id,
      :sku,                   # The variant's SKU.
      :barcode,               # Returns the barcode value of the variant.
      :price,                 # Variant’s price.
      :quantity_in_stock,     # How many of this variants are in stock for this shop.
      :allow_backorder,       # Whether to allow items with no inventory to be added to the cart    
      :status,                # Current status: active, inactive, deleted
      :weight,                # The weight of the variant. This will always be in metric grams.
      :length,                # Length of variant in inches
      :width,                 # Width of variant in inches
      :height,                # Height of variant in inches
      :option1,               # Returns the value of option1 for given variant
      :option2,               # If a product has a second option defined, then returns the value of this variant's option2.
      :option3,               # If a product has a third option defined, then returns the value of this variant's option3.  
      :requires_shipping,     # Returns true if the variant is shippable or false if it is a service or a digital good.    
      :taxable                # Returns true if the variant is taxable or false if it is not.
  
    def self.find_by_options(product_id, option1=nil, option2=nil, option3=nil)
      
      # Create the vars that will become the full conditions statement
      where  = ['product_id=?']
      values = [product_id]
      
      # Append option values if they exist
      
      if option1
        where  << 'option1=?'
        values << option1
      end
      
      if option2
        where  << 'option2=?'
        values << option2
      end
      
      if option3
        where  << 'option3=?'
        values << option3
      end
      
      # Combine all the options into a single conditions statement
      conditions = [ where.join(' AND ') ].concat(values)
      
      # Return whatever is found
      return Variant.where(conditions).first
    end
      
    # Concatenation of all the variant's option values, joined by " / "
    def title
      return self.options.join(' / ')
    end
    
    def options
      arr = []
      arr << self.option1 if self.option1 && self.option1.strip.length > 0
      arr << self.option2 if self.option2 && self.option2.strip.length > 0
      arr << self.option3 if self.option3 && self.option3.strip.length > 0
      return arr
    end
          
  end
end

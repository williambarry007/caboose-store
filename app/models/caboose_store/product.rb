module CabooseStore        
  class Product < ActiveRecord::Base
    self.table_name = "store_products"
    
    belongs_to :vendor
    has_many :categories, :through => :category_memberships
    has_many :category_memberships
    has_many :variants
    has_many :product_images
    has_many :reviews
  
    attr_accessible :id,
      :title,
      :description,
      :vendor_id,    
      :handle,
      :seo_title,
      :seo_description,    
      :option1,
      :option2,
      :option3,
      :default1,
      :default2,
      :default3,
      :status,
      :alternate_id
    
    def options
      arr = []
      arr << self.option1 if !self.option1.nil? && self.option1.strip.length > 0
      arr << self.option2 if !self.option2.nil? && self.option2.strip.length > 0
      arr << self.option3 if !self.option3.nil? && self.option3.strip.length > 0
      return arr
    end
  
    def most_popular_variant
    	self.variants.order('price DESC').first
    end
  
    def featured_image
    	self.product_images.reject{|p| p.nil?}.first
    end
    
    def price_varies
      arr = variants.collect{ |v| v.price }.uniq
      return arr.count > 0
    end
    
    def price_range
      min = 100000
      max = 0
      variants.each do |v|
        next if v.nil? || v.price.nil?
        min = v.price if v.price < min
        max = v.price if v.price > max
      end
      return [min, max]
    end
    
    def url
      return "/products/#{self.id}"
    end
    
    def related_items
      return []
    end
    
    def in_stock
      return Variant.where(:product_id => self.id).where("quantity_in_stock > 0").count > 0    
    end
    
    # Returns non deleted variants
    def live_variants
      return self.variants.where(:status => ['Active', 'Inactive'])
    end
      
  end
end
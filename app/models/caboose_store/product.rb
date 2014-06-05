module CabooseStore
  class Product < ActiveRecord::Base
    self.table_name = 'store_products'
    
    belongs_to :vendor, :class_name => 'CabooseStore::Vendor'
    has_many :customizations, :class_name => 'CabooseStore::Product', :through => :customization_memberships
    has_many :customization_memberships, :class_name => 'CabooseStore::CustomizationMembership'
    has_many :categories, :class_name => 'CabooseStore::Category', :through => :category_memberships
    has_many :category_memberships, :class_name => 'CabooseStore::CategoryMembership'
    has_many :variants, :class_name => 'CabooseStore::Variant'
    has_many :product_images, :class_name => 'CabooseStore::ProductImage'
    has_many :proudct_inputs, :class_name => 'CabooseStore::ProductInput'
    has_many :reviews, :class_name => 'CabooseStore::Review'
    
    default_scope order('store_products.sort_order')
    
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
      :alternate_id,
      :custom_input,
      :sort_order
      
    #
    # Class Methods
    #
    
    def self.with_images
      joins(:product_images)
    end
    
    def self.active
      where(:status => 'Active')
    end
    
    def self.by_title
      order('title')
    end
    
    #
    # Instance Methods
    #
    
    def options
      options = []
      
      options << self.option1 if !self.option1.nil? && self.option1.strip.length > 0
      options << self.option2 if !self.option2.nil? && self.option2.strip.length > 0
      options << self.option3 if !self.option3.nil? && self.option3.strip.length > 0
      
      return options
    end
    
    def most_popular_variant
      self.variants.where('price > ? AND status != ?', 0, 'Deleted').order('price ASC').first
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
      
      variants.each do |variant|
        next if variant.nil? or variant.price < 0
        min = variant.price if variant.price < min
        max = variant.price if variant.price > max
      end
      
      return [min, max]
    end
    
    def url
      "/products/#{self.id}"
    end
    
    def related_items
      Array.new # TODO should be obvious
    end
    
    def in_stock
      Variant.where(:product_id => self.id).where('quantity_in_stock > 0').count > 0
    end
    
    def input_required?
      !self.custom_input.nil?
    end
    
    def active_customizations
      self.customizations.where(:status => 'Active')
    end
    
    def live_variants
      
      # Return variants that haven't been "deleted"
      self.variants.where(:status => ['Active', 'Inactive'])
    end
  end
end
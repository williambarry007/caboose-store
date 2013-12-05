module CabooseStore
  class Category < ActiveRecord::Base
    self.table_name = "store_categories"
    
    belongs_to :parent, :class_name => 'Category', :foreign_key => 'parent_id'
    has_many :children, :class_name => 'Category', :foreign_key => 'parent_id', :order => 'name'  
    has_many :products, :through => :category_memberships, :order => 'title'
    has_many :category_memberships
    has_attached_file :image,
      :path => "categories/:id_:style.jpg",
      :default_url => '/categories/:id_:style.jpg',
      :styles => {
        :tiny   => '100x100>',
        :thumb  => '250x250>',
        :medium => '400x400>',
        :large  => '800x800>',
        :huge   => '1200x1200>'
      }
    
    attr_accessible :id, :parent_id, :name, :url, :slug
    
    def ancestry
      return [self] if self.parent.nil?
      arr = self.parent.ancestry
      arr << self
      return arr 
    end
  
    def self.options(selected_id = nil)     
      arr = []
      self.where(:parent_id => nil).reorder('name').all.each do |cat|
        self.options_helper(cat, selected_id, arr)
      end
      return arr        
    end
    
    def self.options_helper(cat, selected_id, arr, prefix = "")
      arr << {
        :value => cat.id,
        :text => "#{prefix}#{cat.name}"
      }
      cat.children.each do |cat2|
        self.options_helper(cat2, selected_id, arr, "#{prefix} - ")
      end
    end
  
    def featured_image(size)
    	if self.products == [] 
    		return 'http://s3.amazonaws.com/categories/no_image.jpg'
    	end
    	
    	return self.products.reject{|p| p.featured_image.nil? || p.nil?}.first.featured_image.url(size) unless self.products.first.product_images == []
    	return self.products.reject{|p| p.featured_image.nil? || p.nil?}.second.featured_image.url(size) unless self.products.second.product_images == []
    	return self.products.reject{|p| p.featured_image.nil? || p.nil?}.last.featured_image.url(size) unless self.products.last.product_images == []
    	
    end
    
    def self.get_slug(str)
      return str.gsub(' ', '-').downcase
    end
    
  end
end

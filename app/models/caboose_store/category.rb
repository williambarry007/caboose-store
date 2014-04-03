#
# Category
#
# :: Class Methods
# :: Instance Methods

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
    
    #
    # Class Methods
    #
    
    def self.get_slug(str)
      str.gsub(' ', '-').downcase
    end
    
    def self.top_level
      CabooseStore::Category.find_by_url('/products').children
    end
    
    def self.sample(number)
      CabooseStore::Category.top_level.collect { |category| category if category.active_products.count > 0 }.compact.sample(number)
    end
    
    def self.options(selected_id = nil)     
      options = []
      self.where(parent_id: nil).reorder('name').all.each { |category| self.options_helper(category, selected_id, options) }
      return options
    end
    
    def self.options_helper(category, selected_id, options, prefix="")
      options << { value: category.id, text: "#{prefix}#{category.name}" }
      category.children.each { |category_2| self.options_helper(category_2, selected_id, options, "#{prefix} - ") }
    end
    
    #
    # Instance Methods
    #
    
    def active_products
      self.products.where(status: 'Active')
    end
    
    def ancestry
      return [self] if self.parent.nil?
      ancestors = self.parent.ancestry
      ancestors << self
      return ancestors 
    end
    
    def featured_image(size)
      return 'http://s3.amazonaws.com/categories/no_image.jpg' if self.products == []
      return self.products.reject{|p| p.featured_image.nil? || p.nil?}.first.featured_image.url(size) unless self.products.first.product_images == []
      return self.products.reject{|p| p.featured_image.nil? || p.nil?}.second.featured_image.url(size) unless self.products.second.product_images == []
      return self.products.reject{|p| p.featured_image.nil? || p.nil?}.last.featured_image.url(size) unless self.products.last.product_images == []
    end
  end
end

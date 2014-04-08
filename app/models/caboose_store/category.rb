#
# Category
#
# :: Class Methods
# :: Instance Methods

module CabooseStore
  class Category < ActiveRecord::Base
    self.table_name = "store_categories"
    
    belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id'
    has_many :children, class_name: 'Category', foreign_key: 'parent_id', order: 'name'    
    has_many :products, through: :category_memberships, order: 'title'
    has_many :category_memberships
    
    has_attached_file :image,
      path: "categories/:id_:style.jpg",
      default_url: '/categories/:id_:style.jpg',
      styles: {
        tiny:   '100x100>',
        thumb:  '250x250>',
        medium: '400x400>',
        large:  '800x800>',
        huge:   '1200x1200>'
      }
    
    validates_attachment_content_type :image, content_type: %w(image/jpeg image/jpg image/png)
    
    attr_accessible :id, :parent_id, :name, :url, :slug
    
    #
    # Class Methods
    #
    
    def self.root
      self.find_by_url('/products')
    end
    
    def self.top_level
      self.root.children
    end
    
    def self.sample(number)
      CabooseStore::Category.top_level.collect { |category| category if category.active_products.any? }.compact.sample(number)
    end
    
    #
    # Instance Methods
    #
    
    def generate_slug
      self.name.gsub(' ', '-').downcase
    end
    
    def update_child_slugs
      return if self.children.nil? or self.children.empty?
      
      self.children.each do |child|
        child.update_attribute(:url, "#{self.url}/#{child.slug}")
        child.update_child_slugs
      end
    end
    
    def active_products
      self.products.where(status: 'Active')
    end
    
    def ancestry
      return [self] if self.parent.nil?
      ancestors = self.parent.ancestry
      ancestors << self
      return ancestors 
    end
  end
end

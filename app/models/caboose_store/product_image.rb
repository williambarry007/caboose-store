module CabooseStore
  class ProductImage < ActiveRecord::Base
    self.table_name = "store_product_images"
    
    belongs_to :product
    has_many :product_image_variants
    has_many :variants, :through => :product_image_variants    
      
    attr_accessible :id, :title  
    has_attached_file :image,
      #:path => "#{Rails.root}/public/products/:product_id_:id_:style.:extension",
      :path => "products/:product_id_:id_:style.:extension",
      :default_url => '/products/:id_:style.:extension',
      :styles => {
        :tiny   => '100x100>',
        :thumb  => '250x250>',
        :medium => '400x400>',
        :large  => '800x800>',
        :huge   => '1200x1200>'
      }  
    
    validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png"]
    
    def url(size) # 'tiny', 'thumb', 'medium', 'large', 'huge'
      self.image.url(size)
    	#"https://s3.amazonaws.com/tuskwear/products/#{self.product_id}_#{self.id}_#{size}.jpg"
    end
  end
end
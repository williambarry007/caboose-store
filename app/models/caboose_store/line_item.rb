module CabooseStore
  class LineItem < ActiveRecord::Base
    self.table_name = 'store_line_items'
    
    belongs_to :variant
    belongs_to :order, :dependent => :destroy
    belongs_to :parent, :class_name => 'LineItem', :foreign_key => 'parent_id'
    has_many :children, :class_name => 'LineItem', :foreign_key => 'parent_id'
    
    attr_accessible :id,
      :variant_id,
      :parent_id,
      :quantity,
      :price,
      :notes,
      :order_id,
      :status,
      :tracking_number,
      :custom1,
      :custom2,
      :custom3
    
    #
    # Validations
    #
    
    validates :quantity, :numericality => { :greater_than_or_equal_to => 0 }
    validate :quantity_in_stock
    
    def quantity_in_stock
      errors.add(:base, "There #{self.variant.quantity > 1 ? 'are' : 'is'} only #{self.variant.quantity} left in stock.") if self.variant.quantity - self.quantity < 0
    end
    
    #
    # Callbacks
    #
    
    before_save :update_price
    after_save { |line_item| line_item.order.calculate_total }
    
    #
    # Methods
    #
    
    def update_price(line_item=self)
      line_item.price = line_item.variant.price * line_item.quantity
    end
    
    def subtotal
      (self.price || 0) * (self.quantity || 0) / 100 * 100
    end
    
    def as_json(options={})
      self.attributes.merge({
        :variant => self.variant,
        :title => if self.variant.product.variants.count > 1
          "#{self.variant.product.title} - #{self.variant.title}"
        else
          self.variant.product.title
        end
      })
    end
  end
end

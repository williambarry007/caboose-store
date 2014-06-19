module CabooseStore
  class OrderLineItem < ActiveRecord::Base
    self.table_name = 'store_order_line_items'
    
    belongs_to :variant
    belongs_to :order
    belongs_to :parent, :class_name => 'OrderLineItem', :foreign_key => 'parent_id'
    has_many :children, :class_name => 'OrderLineItem', :foreign_key => 'parent_id'
    
    attr_accessible :id,
      :variant_id,
      :parent_id,
      :quantity,
      :quantity_shipped,
      :custom_input,
      :notes,
      :order_id,
      :status,
      :tracking_number,
      :unit_price
    
    def price
      
      # Set price initially off of the associated variant
      price = self.variant.price
      
      # Iterate over any customizations and increment the price if relevant
      self.customizations.each { |customization| price += customization.variant.price || 0 }
      
      # Return price multiplied by quantity
      return price * self.quantity.to_f / 100 * 100
    end
    
    def subtotal
      (self.price || 0) * (self.quantity || 0) / 100 * 100
    end
    
    def cart_info
      info = {
        :id           => self.id,
        :parent_id    => self.parent_id,
        :variant      => self.variant,
        :quantity     => self.quantity,
        :price        => self.price,
        :title        => "#{self.variant.product.title} #{self.variant.title}",
        :custom_label => self.variant.product.custom_input,
        :custom_input => self.custom_input,
        :notes        => self.notes
      }
      
      # Find any and all customizations
      info[:customizations] = self.customizations.collect { |customization| customization.cart_info } if parent_id.nil? && self.customizations.any?
      
      return info
    end
    
    def customizations
      self.children
    end
    
    def is_a_customization?
      !self.parent_id.nil?
    end
  end
end

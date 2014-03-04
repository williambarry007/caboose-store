module CabooseStore
  class OrderLineItem < ActiveRecord::Base
    self.table_name = "store_order_line_items"
    
    belongs_to :variant
    belongs_to :order  
    attr_accessible :id, :variant_id, :quantity, :quantity_shipped
    
    def subtotal
      self.variant.price * self.quantity / 100 * 100
    end
    
    def cart_info
      {
        id:       self.id,
        quantity: self.quantity,
        variant:  self.variant,
        title:    "#{self.variant.product.title}<br />#{self.variant.title}"
      }
    end
  end
end

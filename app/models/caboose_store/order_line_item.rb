module CabooseStore
  class OrderLineItem < ActiveRecord::Base
    self.table_name = "store_order_line_items"
    
    belongs_to :variant
    belongs_to :order  
    attr_accessible :id, :variant_id, :quantity, :quantity_shipped
    
    def subtotal
      return self.unit_price * self.quantity
    end
  end
end

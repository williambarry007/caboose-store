module CabooseStore        
  class Order < ActiveRecord::Base
    include CabooseStore::Concerns::PaymentProcessor
    
    self.table_name = "store_orders"
    
    belongs_to :customer, :class_name => 'Caboose::User'
    belongs_to :shipping_address, :class_name => 'Address'
    belongs_to :billing_address, :class_name => 'Address'
    has_many :discounts, :through => :order_discounts
    has_many :order_discounts
    has_many :order_line_items
    
    attr_accessible :id,
      :order_number,      # Customer-set unique number of the order
      :subtotal,              
      :tax,
      :shipping_method,
      :shipping_method_code,
      :shipping,
      :discount,
      :total,    
      :status,            # The current order status. One of: cart, pending, backordered, fulfilled
      :payment_status,    # The current payment status. One of: nil, 'pending', 'authorized', 'captured', 'voided', 'refunded'        
      :notes,             # The note which is attached to the order.
      :referring_site,    # Contains the url of the referrer that brought the customer to your store
      :landing_site,      # Contains the path of the landing site the customer used. The first page that the customer saw when he/she reached the store.
      :landing_site_ref,  # Looks at the landing site and extracts a reference parameter from it.
      :cancel_reason,     # The reason selected when cancelling the order. One of: 'inventory', 'customer', 'fraud', 'other'
      :date_created,
      :date_authorized,
      :date_captured,
      :date_cancelled    
    
    def authorized?
      self.financial_status == 'authorized'
    end
      
    def test?
      return self.customer_id == 1
    end
    
    def line_items
      return self.order_line_items
    end
    
    def subtotal
      return self.order_line_items.inject(0.0){ |sum,li| sum + li.subtotal }
    end
    
    # Array of any Line Items which have been fulfilled (marked as shipped on the order screen).
    def fulfilled_line_items
      return self.order_line_items.where(:status => 'shipped').all
    end
    
    # Array of those Line Items which have not yet been fulfilled (marked as shipped on the order screen).
    def unfulfilled_line_items
      return self.order_line_items.where('status != ?', 'shipped').all
    end
    
    def cancelled
      return self.status == 'cancelled'
    end
    
    # Returns true if there is at least one item in the order that requires shipping, and returns false otherwise
    def requires_shipping
      requires = false
      self.order_line_items.each do |li|
        if li.variant.requires_shipping
          requires = true
          break
        end
      end
      return requires
    end
    
    def calculate_total
      self.calculate_discount
      
      self.total = self.subtotal
      self.total += self.tax if self.tax
      self.total += self.shipping if self.shipping
      self.total += self.handling if self.handling
      self.total -= self.discount if self.discount
      
      return self.total.round(2)
    end
    
    def calculate_discount        
      
      percentage_off = 0.0
      amount_off = 0.0
      no_shipping = false
      no_tax = false
      
      self.discounts.each do |d|
        percentage_off = percentage_off + d.amount_percentage
        amount_off = amount_off + d.amount_flat
        no_shipping = true if d.no_shipping
        no_tax = true if d.no_tax
      end
      
      x = 0.0
      x = x + self.subtotal * percentage_off if percentage_off > 0
      x = x + amount_off if amount_off > 0
      x = x + self.shipping if no_shipping
      x = x + self.tax if no_tax
  
      self.discount = x
      return self.discount / 100 * 100
    end
  end
end

#
# Order
#
# :: Class Methods
# :: Instance Methods

module CabooseStore        
  class Order < ActiveRecord::Base
    self.table_name  = 'store_orders'
    self.primary_key = 'id'
    
    belongs_to :customer, :class_name => 'Caboose::User'
    belongs_to :shipping_address, :class_name => 'Address'
    belongs_to :billing_address, :class_name => 'Address'
    has_many :discounts, :through => :order_discounts
    has_many :order_discounts
    has_many :line_items, :after_add => :calculate_total, :after_remove => :calculate_total
    
    attr_accessible :id,
      :order_number,
      :subtotal,
      :tax,
      :shipping_method,
      :shipping_method_code,
      :shipping,
      :discount,
      :amount_discounted,
      :total,
      :status,
      :payment_status,
      :notes,
      :referring_site,
      :landing_site,
      :landing_site_ref,
      :cancel_reason,
      :date_created,
      :date_authorized,
      :date_captured,
      :date_cancelled,
      :email,
      :customer_id,
      :payment_id,
      :gateway_id,
      :financial_status,
      :shipping_address_id,
      :billing_address_id,
      :landing_page,
      :landing_page_ref,
      :handling,
      :transaction_d,
      :auth_code,
      :alternate_id,
      :auth_amount,
      :date_shipped,
      :transaction_service,
      :transaction_id
    
    #
    # Callbacks
    #
    
    before_update :calculate_total
    
    #
    # Methods
    #
    
    def as_json(option={})
      self.attributes.merge({
        :line_items => self.line_items
      })
    end
    
    def decrement_quantities
      return false if self.decremented
      
      self.line_items.each do |line_item|
        line_item.variant.update_attribute(:quantit, line_item.variant.quantity - line_item.quantity)
      end
      
      self.update_attribute(:decremented, true)
    end
    
    def increment_quantities
      return false if !self.decremented
      
      self.line_items.each do |line_item|
        line_item.variant.update_attribute(:quantity, line_item.variant.quantity - line_item.quantity)
      end
      
      self.update_attribute(:decremented, false)
    end
    
    def resend_confirmation
      OrdersMailer.customer_new_order(self).deliver
    end
    
    def authorized?
      self.financial_status == 'authorized' or PaymentProcessor.authorized?(self)
    end
      
    def test?
      self.status == 'testing'
    end
    
    def cancelled?
      self.status == 'cancelled'
    end
    
    def authorize
    end
    
    def capture
    end
    
    def refuned
    end
    
    def void
    end
    
    def fulfilled_line_items
      self.line_items.where(:status => 'shipped').all
    end
    
    def unfulfilled_line_items
      self.line_items.where('status != ?', 'shipped').all
    end
    
    def calculate_total(order=self)
      order.update_column(:subtotal, (order.line_items.collect { |line_item| line_item.price }.inject { |sum, price| sum + price } * 100).ceil / 100.00)
      order.update_column(:tax, (self.subtotal * TaxCalculator.tax_rate(order.shipping_address) * 100).ceil / 100.00) if order.shipping_address
      order.update_column(:shipping, (CabooseStore.fixed_shipping * 100).ceil / 100.00) if CabooseStore::fixed_shipping
      order.update_column(:total, (([self.subtotal, self.tax, self.shipping].compact.inject { |sum, price| sum + price } * 100).ceil / 100.00))
    end
    
    #def calculate_net
    #  total  = self.subtotal
    #  total += self.tax      if self.tax
    #  total += self.shipping if self.shipping
    #  total += self.handling if self.handling
    #  
    #  return total.round(2)
    #end
    
    #def calculate_total(update_gift_card=false)
    #  # self.calculate_discount
    #  
    #  self.total  = self.subtotal
    #  self.total += self.tax      if self.tax
    #  self.total += self.shipping if self.shipping
    #  self.total += self.handling if self.handling
    #  
    #  if self.discounts.any?
    #    discount = self.discounts.first
    #    
    #    if self.total >= discount.amount_current
    #      self.total -= discount.amount_current
    #      discount.update_attribute(:amount_current, 0) if update_gift_card
    #    else
    #      discount.update_attribute(:amount_current, discount.amount_current - self.total) if update_gift_card
    #      self.total = 0
    #    end
    #  end
    #  
    #  self.save
    #  
    #  return self.total.round(2)
    #end
  end
end

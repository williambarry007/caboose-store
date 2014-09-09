module CabooseStore
  class OrdersMailer < ActionMailer::Base
    default :from => 'woodsnwater.actionmailer@gmail.com'
    
    # Sends a confirmation email to the customer about a new order 
    def customer_new_order(order)
      @order = order
      ap order
      ap order.customer
      ap order.customer.email if !order.customer.nil?
      mail(:to => order.customer ? order.customer.email : order.email, :subject => 'Thank you for your order!')
    end
    
    # Sends a notification email to the fulfillment dept about a new order 
    def fulfillment_new_order(order)
      @order = order
      mail(:to => CabooseStore::fulfillment_email, :subject => 'New Order')
    end
    
    # Sends a notification email to the shipping dept that an order is ready to be shipped
    def shipping_order_ready(order)
      @order = order
      mail(:to => CabooseStore::shipping_email, :subject => 'Order ready for shipping')
    end
    
    # Sends a notification email to the customer that the status of the order has been changed
    def customer_status_updated(order)
      @order = order
      mail(:to => order.customer ? order.customer.email : order.email, :subject => 'Order status update')
    end
  end
end

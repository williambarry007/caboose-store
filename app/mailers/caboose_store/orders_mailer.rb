module CabooseStore
  class OrdersMailer < ActionMailer::Base
    default from: "woodsnwater.actionmailer@gmail.com"
    
    # Sends a confirmation email to the customer about a new order 
    def customer_new_order(order)
      @order = order
      mail(to: order.customer.email, subject: "Thank you from TuskWear!")
    end
    
    # Sends a notification email to the fulfillment dept about a new order 
    def fulfillment_new_order(order)
      @order = order
      #config = YAML::load(File.open("#{Rails.root}/config/tuskwear.yml"))
      #fulfillment_email = config[Rails.env]['order_fulfillment_email']  
      #mail(:to => fulfillment_email, :subject => "New Order")
      mail(to: CabooseStore::fulfillment_email, subject: "New Order")
      #mail(:to => 'william@nine.is', :subject => "New Order")
    end
    
    # Sends a notification email to the shipping dept that an order is ready to be shipped
    def shipping_order_ready(order)
      @order = order
      #config = YAML::load(File.open("#{Rails.root}/config/tuskwear.yml"))
      #shipping_email = config[Rails.env]['order_shipping_email']
      #mail(:to => shipping_email, :subject => "Order ready for shipping")
      mail(to: CabooseStore::shipping_email, subject: "Order ready for shipping")
    end
    
    # Sends a notification email to the customer that the status of the order has been changed
    def customer_status_updated(order)
      @order = order
      mail(to: order.customer.email, subject: "TuskWear Order Status Update")
    end
  end
end
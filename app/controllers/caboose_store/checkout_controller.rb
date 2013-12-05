module CabooseStore
  class CheckoutController < ApplicationController
  
    helper :authorize_net
    protect_from_forgery :except => :authnet_relay_response
    
    # GET /checkout  
  	def index
  	  @order = Order.find(session['cart_id'])
      @is_logged_in = logged_in?
      if @is_logged_in
        @order.customer_id = logged_in_user.id
        @order.save
      end
  	end
  	
  	# GET /checkout/shipping-address
  	def shipping_address
  	  @order = Order.find(session['cart_id'])
  	end
  	
  	# PUT /checkout/shipping-address
  	def update_shipping_address
  	  resp = Caboose::StdClass.new
  	  
  	  order = Order.find(session['cart_id'])
  	  a = order.shipping_address ? order.shipping_address : Address.new	  
  	  a.name      = params[:name]
      a.company   = params[:company] 
      a.address1  = params[:address1]
      a.address2  = params[:address2]
      a.city      = params[:city]
      a.state     = params[:state]
      a.zip       = params[:zip]
      
      if (a.name.strip.length == 0)
        resp.error = "A name is required."
      elsif (a.address1.strip.length == 0)
        resp.error = "An address is required."
      elsif (a.city.strip.length == 0)
        resp.error = "A city is required."
      elsif (a.state.strip.length == 0)
        resp.error = "A state is required."
      elsif (a.zip.strip.length < 5)
        resp.error = "A valid zip code is required."
      end
      
      if (resp.error.nil?)
        a.save
        tax_rate = TaxCalculator.tax_rate(a)
        order.tax = order.subtotal * tax_rate
        order.shipping_address_id = a.id
        order.calculate_total      
        order.save
        resp.redirect = '/checkout/shipping'    
      end
      render :json => resp
  	end
  	
  	# GET /checkout/shipping
  	def shipping
  	  @order = Order.find(session['cart_id'])	  
  	end
  	
  	# GET /checkout/shipping-rates
  	def shipping_rates
  	  order = Order.find(session['cart_id'])	  
  	  render :json => ShippingCalculator.rates(order)	  	  
  	end
  	
  	# PUT /checkout/shipping-method
  	def update_shipping_method	  
  	  resp = Caboose::StdClass.new	  
  	  order = Order.find(session['cart_id'])
  	  
  	  code = params[:shipping_method_code]
  	  if code.nil? || code.strip.length == 0
  	    resp.error = "You must select a shipping method."
  	  else	  
  	    order.shipping = params[:shipping].to_f/100
  	    order.shipping_method = params[:shipping_method]
  	    order.shipping_method_code = params[:shipping_method_code]
  	    order.handling = order.shipping * 0.05
  	    order.calculate_total	  
  	    order.save	  
  	    resp.redirect = '/checkout/billing'
  	  end
      render :json => resp	  	  
  	end
  	
  	# GET /checkout/billing
  	def billing
  	  @order = Order.find(session['cart_id'])
  	  @logged_in_user = logged_in_user
  	  @sim_transaction = AuthorizeNet::SIM::Transaction.new(
        AUTHORIZE_NET_CONFIG['api_login_id'], 
        AUTHORIZE_NET_CONFIG['api_transaction_key'], 
        @order.total, 
        :relay_url => 'https://www.tuskwearcollection.com/checkout/authnet-relay-response',
        :transaction_type => 'AUTH_ONLY' #AuthorizeNet::Type::AUTHORIZE_ONLY
      )	  
  	end
  	
  	# POST /checkout/authnet-relay-response  
    def authnet_relay_response
      sim_response = AuthorizeNet::SIM::Response.new(params)
      if sim_response.success?(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['merchant_hash_value'])      
        if (params[:x_response_code].to_i == 1) # Approved
          order = Order.find(params[:x_invoice_num])
          order.date_authorized = DateTime.now
          order.transaction_id  = params[:x_trans_id]
          order.auth_code = params[:x_auth_code]
          order.auth_amount = order.total
          order.financial_status = 'authorized'
          order.status = 'pending'
          order.save        
        end      
      end
      render :text => sim_response.direct_post_reply('https://www.tuskwearcollection.com/checkout/authnet-receipt', :include => true)
    end
    
    # GET /checkout/authnet-receipt
    def authnet_receipt
      js = ""
      if (params[:x_response_code].to_i == 1) # Approved
        js = "parent.window.location = '/checkout/finalize';"
      else 
        msg = "<p class='note error'>There was an error processing your card:<br /><br />#{params[:x_response_reason_text]}</p>"
        msg = msg.gsub('"', '')
        js = "parent.$('#message').html(\"#{msg}\");"
      end
      render :text => "<script type='text/javascript'>#{js}</script>"
    end
  		
  	# GET /checkout/finalize
  	def finalize
  	  order = Order.find(session['cart_id'])
  	  
  	  # Make sure they didn't come to the page twice
  	  if order.line_items.count == 0
  	    redirect_to "/"
  	    return
  	  end
  	  
  	  # Notify the customer
  	  OrdersMailer.customer_new_order(order).deliver
  	  
  	  # Notify the fulfillment center
  	  OrdersMailer.fulfillment_new_order(order).deliver
  	  
  	  # Add the order to quickbooks
  	  #Quickbooks.create_order(order)	  
  	  
  	  # Clear everything
  	  session['cart_id'] = nil
  	  
  	  redirect_to '/checkout/thank-you'
  	end
  	
  	def thank_you	  
  	end
  	
  end
end

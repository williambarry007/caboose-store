module CabooseStore
  class CheckoutController < ApplicationController
    before_filter :inject_assets
    before_filter :get_order, except: [:relay]
    before_filter :ensure_order, only: [:index, :shipping, :billing]
    
    def inject_assets
      Caboose::javascripts << 'caboose_store/checkout'
    end
    
    def get_order
      @order = Order.find(session[:cart_id])
    end
    
    def ensure_order
      redirect_to '/checkout/empty' if @order.line_items.empty?
    end
    
    # GET /checkout/empty
    def empty
    end
    
    # GET /checkout
    def index
      if logged_in?
        @order.customer_id = logged_in_user.id
        @order.save
      end
    end
    
    # PUT /checkout/shipping-address
    def update_address
      
      # Grab or create addresses
      shipping_address = if @order.shipping_address then @order.shipping_address else Address.new end
      billing_address  = if @order.billing_address  then @order.billing_address  else Address.new end
    
      # Shipping address
      shipping_address.first_name = params[:shipping][:first_name]
      shipping_address.last_name  = params[:shipping][:last_name]
      shipping_address.company    = params[:shipping][:company]
      shipping_address.address1   = params[:shipping][:address1]
      shipping_address.address2   = params[:shipping][:address2]
      shipping_address.city       = params[:shipping][:city]
      shipping_address.state      = params[:shipping][:state]
      shipping_address.zip        = params[:shipping][:zip]
    
      # Billing address
      if params[:shipping][:use_as_billing]
        billing_address.update_attributes(shipping_address.attributes)
      else
        billing_address.first_name = params[:billing][:first_name]
        billing_address.last_name  = params[:billing][:last_name]
        billing_address.company    = params[:billing][:company]
        billing_address.address1   = params[:billing][:address1]
        billing_address.address2   = params[:billing][:address2]
        billing_address.city       = params[:billing][:city]
        billing_address.state      = params[:billing][:state]
        billing_address.zip        = params[:billing][:zip]
      end
    
      # Require fields
      if (
        shipping_address.first_name.strip.length == 0 or billing_address.first_name.strip.length == 0 ||
        shipping_address.last_name.strip.length  == 0 or billing_address.last_name.strip.length  == 0
      )
        render json: { error: 'A name is required.' } and return
      elsif (shipping_address.address1.strip.length == 0 or billing_address.address1.strip.length == 0)
        render json: { error: 'An address is required.' } and return
      elsif (shipping_address.city.strip.length == 0 or billing_address.city.strip.length == 0 )
        render json: { error: 'An city is required.' } and return
      elsif (shipping_address.state.strip.length == 0 or billing_address.state.strip.length == 0)
        render json: { error: 'An state is required.' } and return
      elsif (shipping_address.zip.strip.length < 5 or billing_address.zip.strip.length < 5)
        render json: { error: 'An valid zip code is required.' } and return
      end
      
      # Save address info; generate ids
      shipping_address.save
      billing_address.save
      
      # Associate address info with order
      @order.shipping_address_id = shipping_address.id
      @order.billing_address_id  = billing_address.id
      
      # Calculate tax and shipping
      @order.tax = @order.subtotal * TaxCalculator.tax_rate(shipping_address)
      
      # Calculate total and save
      @order.calculate_total
      @order.save
      
      render json: { redirect: 'checkout/shipping' }
    end
    
    # GET /checkout/shipping
    def shipping
      @shipping_address = @order.shipping_address
      @shipping_rates   = ShippingCalculator.rates(@order)
    end
    
    # PUT /checkout/shipping-method
    def update_shipping_method
      render json: { error: 'You must select a shipping method.' } and return if params[:shipping_method].nil? or params[:shipping_method][:code].empty?
      
      @order.shipping             = params[:shipping_method][:price].to_f / 100
      @order.shipping_method      = params[:shipping_method][:name]
      @order.shipping_method_code = params[:shipping_method][:code]
      @order.handling             = (@order.shipping * 0.05) / 100 * 100
      
      @order.calculate_total
      @order.save
      
      render json: { redirect: '/checkout/billing' }
    end
    
    # GET /checkout/billing
    def billing
      @shipping_address = @order.shipping_address
      @form_url         = CabooseStore::PaymentProcessor.form_url(@order)
    end
    
    # GET /checkout/relay/:order_id
    def relay
      @order = Order.find(params[:order_id].to_i)
    
      if @order.total > 0 and CabooseStore::PaymentProcessor.authorize(@order, params)
        @order.date_authorized  = DateTime.now
        @order.auth_amount      = @order.total
        @order.financial_status = 'authorized'
        @order.status           = if @order.test? or @order.customer_id == 2684 then 'testing' else 'pending' end
        @order.save
      else
        @order.financial_status = 'unauthorized'
        @order.save
      end
      
      redirect_to '/checkout/finalize'
    end
    
    # GET /checkout/finalize
    def finalize
      
      # Make sure they didn't come to the page twice
      redirect_to '/' and return if @order.line_items.count == 0
      
      if @order.authorized?
        
        # Notify the customer
        OrdersMailer.customer_new_order(@order).deliver
        
        # Notify the fulfillment center
        OrdersMailer.fulfillment_new_order(@order).deliver
        
        # Clear everything
        session[:cart_id] = nil
      end
    end
  end
end

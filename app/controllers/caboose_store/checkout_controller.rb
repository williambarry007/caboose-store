module CabooseStore
  class CheckoutController < CabooseStore::ApplicationController
    helper :authorize_net
    before_filter :ensure_line_items, :only => [:step_one, :step_two]
    
    def ensure_line_items
      redirect_to '/checkout/empty' if @order.line_items.empty?
    end
    
    # GET /checkout || GET /checkout/step-one
    def step_one
    end
    
    # GET /checkout/step-two
    def step_two
      redirect_to '/checkout/step-one' if !@order.shipping_address || !@order.billing_address
    end
    
    # GET /checkout/address
    def address
      render :json => {
        :shipping_address => @order.shipping_address,
        :billing_address => @order.billing_address
      }
    end
    
    # PUT /checkout/address
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
      if params[:use_as_billing]
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
      
      # Save address info; generate ids
      render :json => { :success => false, :errors => shipping_address.errors.full_messages, :address => 'shipping' } and return if !shipping_address.save
      render :json => { :success => false, :errors => billing_address.errors.full_messages, :address => 'billing' } and return if !billing_address.save
      
      # Associate address info with order
      @order.shipping_address_id = shipping_address.id
      @order.billing_address_id  = billing_address.id
      
      #render :json => { :redirect => 'checkout/shipping' }
      render :json => { :success => @order.save, :errors => @order.errors.full_messages }
    end
    
    # GET /checkout/shipping
    def shipping
      render :json => { :rates => ShippingCalculator.rates(@order), :selected_rate => ShippingCalculator.rate(@order) }
    end
    
    # PUT /checkout/shipping
    def update_shipping
      @order.shipping_code = params[:shipping_code]
      render :json => { :success => @order.save, :errors => @order.errors.full_messages, :order => @order }
    end
    
    # GET /checkout/payment
    def payment
      @sim_transaction = AuthorizeNet::SIM::Transaction.new(
        CabooseStore::authorize_net_login_id,
        CabooseStore::authorize_net_transaction_key,
        @order.total,
        :relay_url => "#{CabooseStore::root_url}/checkout/relay/#{@order.id}",
        :transaction_type => 'AUTH_ONLY',
        :test => true
      )
      
      render :layout => false
    end
    
    # POST /checkout/relay/:order_id
    def relay
      ap 'IN RELAY FUNCTION'
      @order = CabooseStore::Order.find(params[:order_id])
      @success = params[:x_response_code] == '1'
      @message = params[:x_response_reason_text]
      
      if @success
        @order.update_attributes(
          :financial_status => 'authorized',
          :status => 'pending',
          :date_authorized => DateTime.now,
          :auth_amount => @order.total,
          :transaction_id => params[:x_trans_id]
        )
      else
        @order.update_attribute(:financial_status, 'unauthorized')
      end
      
      render :layout => false
    end
    
    # GET /checkout/empty
    def empty
    end
    
    # GET /checkout/thanks
    def thanks
    end
    
    # GET /checkout/discount
    #def discount
    #  # TODO make it possible to use multiple discounts
    #  
    #  @gift_card = @order.discounts.first
    #end
    
    # POST /checkout/update-discount
    #def add_discount
    #  gift_card = Discount.find_by_code(params[:gift_card_number])
    #  
    #  render :json => { :error => true, :message => 'Gift card not found.' } and return if gift_card.nil?
    #  render :json => { :error => true, :message => 'Gift card has no remaining funds.' } and return if gift_card.amount_current <= 0
    #  
    #  @order.discounts.delete_all if @order.discounts.any?
    #  @order.discounts << gift_card
    #  @order.calculate_total
    #  
    #  render :json => { :success => true, :message => 'Gift card added successfully.' }
    #end
    
    #def relay
    #  
    #  # Check to see that the order has a valid total and was authorized
    #  if @order.total > 0 && PaymentProcessor.authorize(@order, params)
    #    
    #    # Update order
    #    @order.date_authorized  = DateTime.now
    #    @order.auth_amount      = @order.total
    #    @order.financial_status = 'authorized'
    #    @order.status           = if @order.test? then 'testing' else 'pending' end
    #    
    #    # Send out notifications
    #    OrdersMailer.customer_new_order(@order).deliver
    #    OrdersMailer.fulfillment_new_order(@order).deliver
    #    
    #    # Clear everything
    #    session[:cart_id] = nil
    #    
    #    # Emit order event
    #    Caboose.plugin_hook('order_authorized', @order)
    #    
    #    # Decrement quantities of variants
    #    @order.decrement_quantities
    #  else
    #    @order.financial_status = 'unauthorized'
    #  end
    #  
    #  @order.save
    #end
    
    # GET /checkout/authorize-by-gift-card
    #def authorize_by_gift_card
    #  if @order.total < @order.discounts.first.amount_current
    #    
    #    # Update order
    #    @order.date_authorized  = DateTime.now
    #    @order.auth_amount      = @order.total
    #    @order.financial_status = 'authorized'
    #    @order.status           = if @order.test? then 'testing' else 'pending' end
    #    
    #    # Send out notifications
    #    OrdersMailer.customer_new_order(@order).deliver
    #    OrdersMailer.fulfillment_new_order(@order).deliver
    #    
    #    # Clear everything
    #    session[:cart_id] = nil
    #    
    #    # Emit order event
    #    Caboose.plugin_hook('order_authorized', @order)
    #    
    #    # Decrement quantities of variants
    #    @order.decrement_quantities
    #    
    #    @order.save
    #    
    #    redirect_to '/checkout/thanks'
    #  else
    #    redirect_to '/checkout/error'
    #  end
    #end
    
  end
end

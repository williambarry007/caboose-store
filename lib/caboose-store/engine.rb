require 'caboose'

module CabooseStore
  class Engine < ::Rails::Engine
    isolate_namespace CabooseStore
    
    # Inject assets
    Caboose::javascripts << 'caboose_store/application'
    Caboose::stylesheets << 'caboose_store/application'
    
    initializer 'caboose_store.assets.precompile' do |app|
      app.config.assets.precompile += [
        
        # Images
        'caboose_store/caboose_logo_small.png',
        'caboose_store/caboose_nav_black.png',
        'caboose_store/caboose_nav.png',
        'caboose_store/default_user_pic.png',
        'caboose_store/loading_green.gif',
        'caboose_store/loading_small_white_on_black.gif',
        'caboose_store/loading_white_on_black.gif',
        
        # Javascript
        'caboose_store/*.js',
        
        # CSS
        'caboose_store/*.css'
      ]      
    end
    
    initializer 'caboose_store.smtp_config' do |app|
      app.config.action_mailer.smtp_settings = CabooseStore::smtp_settings
    end
    
    initializer 'caboose_store.shipping_login' do |app|
      app.config.shipping = CabooseStore::shipping
    end
    
    initializer 'caboose_store.payment_processor', :after => :finish_hook do |app|
      case CabooseStore::payment_processor
        when 'authorize.net'
          CabooseStore::PaymentProcessor = CabooseStore::PaymentProcessors::Authorizenet
        when 'payscape'
          CabooseStore::PaymentProcessor = CabooseStore::PaymentProcessors::Payscape
      end
    end
    
    initializer 'caboose_store.cart', :after => :finish_hook do |app|
      ActiveSupport.on_load(:action_controller) do
        include CabooseStore::BootStrapper
      end
      
      Caboose::User.class_eval do
        self.primary_key = :id
      end
    end
  end
end

module CabooseStore::BootStrapper
  def self.included(base)
    base.before_filter :init_cart
  end
  
  def init_cart
    
    # Primarily for the relay, check for Order ID coming back
    #session[:cart_id] = params[:order_id] if params[:order_id]
    
    # Check if the cart ID is defined and that it exists in the database
    if !session[:cart_id] || !CabooseStore::Order.exists?(session[:cart_id])
      
      # Create an order to associate with the session
      order = CabooseStore::Order.create(
        :status => 'cart',
        :financial_status => 'pending',
        :date_created => DateTime.now,
        :referring_site => request.env['HTTP_REFERER'],
        :landing_page => request.fullpath,
        :landing_page_ref => params[:ref] || nil
      )
      
      order.update_attribute(:shipping_method_code, CabooseStore::default_shipping_method_code) if CabooseStore::default_shipping_method_code
      
      # Define the cart ID
      session[:cart_id] = order.id
    end
    
    # Log the order and set an instance variable up
    ap @order = CabooseStore::Order.find(session[:cart_id])
    session[:new_cart_items] ||= Array.new
  end
end


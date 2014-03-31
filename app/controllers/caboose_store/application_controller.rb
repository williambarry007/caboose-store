
module CabooseStore
  class ApplicationController < Caboose::ApplicationController
    protect_from_forgery
    layout 'layouts/caboose/application'
    helper :all
    before_filter :init_cart
    
    def init_cart
      
      ap "INIT CART"
      ap session[:cart_id]
      
      # Primarily for the relay, check for Order ID coming back
      session[:cart_id] = params[:order_id] if params[:order_id] and request.env['PATH_INFO'].include?('checkout')
      
      # Exit the function if the Cart ID is defined and a corresponding order exists in the database
      return if session[:cart_id] and CabooseStore::Order.exists?(session[:cart_id])
      
      # Otherwise, create an order to associate with the session
      order                  = CabooseStore::Order.new(status: 'cart', date_created: DateTime.now)
      order.referring_site   = request.env['HTTP_REFERER']
      order.landing_page     = request.fullpath
      order.landing_page_ref = params[:ref] if params[:ref]
      order.save
      
      # Set the Cart ID
      session[:cart_id] = order.id
    end
  end
end

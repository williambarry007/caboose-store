
module CabooseStore
  class ApplicationController < Caboose::ApplicationController
    protect_from_forgery
    layout 'layouts/caboose/application'
    helper :all
    # before_filter :init_cart
    # 
    # def init_cart
    #   
    #   # Primarily for the relay, check for Order ID coming back
    #   session[:cart_id] = params[:order_id] if params[:order_id] and request.env['PATH_INFO'].include?('checkout')
    #   
    #   unless session[:cart_id] and Order.exists?(session[:cart_id])
    #     
    #     # Otherwise, create an order to associate with the session
    #     order                  = Order.new(status: 'cart', date_created: DateTime.now)
    #     order.referring_site   = request.env['HTTP_REFERER']
    #     order.landing_page     = request.fullpath
    #     order.landing_page_ref = params[:ref] if params[:ref]
    #     order.save
    #   
    #     # Set the Cart ID
    #     session[:cart_id] = order.id
    #   end
    #   
    #   ap @order = Order.find(session[:cart_id])
    # end
  end
end

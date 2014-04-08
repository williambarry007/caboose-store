require "caboose-store/engine"

module CabooseStore
  mattr_accessor :root_url, :payment_processor, :api_key, :smtp_settings, :shipping,
    :fulfillment_email, :shipping_email, :contact_email, :payscape_username, :payscape_password
end

module CabooseStore::Cart
  def self.included(base)
    base.before_filter :init_cart
  end

  def init_cart

    # Primarily for the relay, check for Order ID coming back
    session[:cart_id] = params[:order_id] if params[:order_id] and request.env['PATH_INFO'].include?('checkout')

    unless session[:cart_id] and CabooseStore::Order.exists?(session[:cart_id])

      # Otherwise, create an order to associate with the session
      order                  = CabooseStore::Order.new(status: 'cart', date_created: DateTime.now)
      order.referring_site   = request.env['HTTP_REFERER']
      order.landing_page     = request.fullpath
      order.landing_page_ref = params[:ref] if params[:ref]
      order.save

      # Set the Cart ID
      session[:cart_id] = order.id
    end

    ap @order = CabooseStore::Order.find(session[:cart_id])
  end
end
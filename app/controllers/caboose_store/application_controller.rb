
module CabooseStore
  class ApplicationController < Caboose::ApplicationController
    protect_from_forgery
    layout 'layouts/caboose/application'
    before_filter :init_cart
    
    def init_cart
      return if session['cart_id'] && Order.exists?(session['cart_id'])
      order = Order.new(:status => 'cart', :date_created => DateTime.now)    
      order.referring_site = request.env['HTTP_REFERER']
      order.landing_page = request.fullpath
      order.landing_page_ref = params[:ref] if params[:ref]    
      order.save    
      session['cart_id'] = order.id;    
    end
  end
end

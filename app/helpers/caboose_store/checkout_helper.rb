module CabooseStore
  module CheckoutHelper
    def caboose_store_cart
      render :partial => '/caboose_store/checkout/cart'
    end
    
    def caboose_store_address_form
      render :partial => '/caboose_store/checkout/address_form'
    end
    
    def caboose_store_shipping_address
      render :partial => '/caboose_store/checkout/shipping_address'
    end
    
    def caboose_store_shipping_method_form
      render :partial => '/caboose_store/checkout/shipping_method_form'
    end
    
    def caboose_store_shipping_method
      render :partial => '/caboose_store/checkout/shipping_method'
    end
    
    def caboose_store_discount
      render :partial => '/caboose_store/checkout/order_discount'
    end
    
    def caboose_store_billing_form
      render :partial => '/caboose_store/checkout/billing_form'
    end
    
    def checkout_nav(i)
      str = ""
      str << "<div id='checkout-nav'>"
      str << "  <ul>"
      str << "    <li class='odd'  id='checkout_nav1'><a href='#{i <= 1 ? '#' : '/checkout/step-one'   }' class='#{i == 1 ? 'current' : (i < 1 ? 'not_done' : 'done')}'><span>User Account </span></a></li>"
      str << "    <li class='even' id='checkout_nav2'><a href='#{i <= 2 ? '#' : '/checkout/step-two'   }' class='#{i == 2 ? 'current' : (i < 2 ? 'not_done' : 'done')}'><span>Addresses    </span></a></li>"
      str << "    <li class='odd'  id='checkout_nav3'><a href='#{i <= 3 ? '#' : '/checkout/step-three' }' class='#{i == 3 ? 'current' : (i < 3 ? 'not_done' : 'done')}'><span>Shipping     </span></a></li>"
      str << "    <li class='even' id='checkout_nav4'><a href='#{i <= 4 ? '#' : '/checkout/step-four'  }' class='#{i == 4 ? 'current' : (i < 4 ? 'not_done' : 'done')}'><span>Payment      </span></a></li>"
      str << "    <li class='odd'  id='checkout_nav5'><a href='#{i <= 5 ? '#' : '/checkout/step-five'  }' class='#{i == 5 ? 'current' : (i < 5 ? 'not_done' : 'done')}'><span>Confirm      </span></a></li>"
      str << "  </ul>"
      str << "</div>"
      return str
    end
  end
end


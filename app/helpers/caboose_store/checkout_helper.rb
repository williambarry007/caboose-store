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
    
    def caboose_store_billing_form
      render :partial => '/caboose_store/checkout/billing_form'
    end
  end
end

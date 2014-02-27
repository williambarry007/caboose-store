module CabooseStore
  module CartHelper
    def line_items(order)
      arr = []
      order.line_items.each do |li|
        v = li.variant
        p = v.product
        
        img = false
        if v.product_images && v.product_images.count > 0
        #  img = v.product_images[0].image.url(:tiny)
        #elsif p.product_images && p.product_images.count > 0
        #  img = p.product_images[0].image.url(:tiny)
        end
            
        arr << {
          'quantity' => li.quantity,
          'variant' => v,
          'variant_title' => "#{p.title}<br />#{v.title}",
          'variant_image' => img
        }
      end
      return arr
    end
    
    def caboose_store_cart
      render partial: '/caboose_store/checkout/cart'
    end
    
    def caboose_store_address_form
      render partial: '/caboose_store/checkout/address_form'
    end
    
    def caboose_store_shipping_address
      render partial: '/caboose_store/checkout/shipping_address'
    end
    
    def caboose_store_shipping_method_form
      render partial: '/caboose_store/checkout/shipping_method_form'
    end
    
    def caboose_store_shipping_method
      render partial: '/caboose_store/checkout/shipping_method'
    end
    
    def caboose_store_billing_form
      render partial: '/caboose_store/checkout/billing_form'
    end
  end
end

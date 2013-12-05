module CabooseStore
  class CartController < ApplicationController  
    
    # GET /cart
    def index    
      @order = self.get_cart
      render :layout => 'layouts/caboose/modal'    
    end
    
    # GET /cart/add/:id
    def add
      v = Variant.find(params[:id])    
      @order = self.get_cart
      
      exists = false
      @order.line_items.each do |li|
        next if li.variant.id != v.id
        li.quantity = li.quantity + 1
        li.save
        exists = true
        break
      end    
      if !exists
        li = OrderLineItem.new
        li.variant = v
        li.quantity = 1
        li.unit_price = v.price
        li.variant_sku = v.sku
        @order.line_items << li      
      end
      @order.save    
      
      render 'caboose_store/cart/index', :layout => 'layouts/caboose/modal'
    end
    
    # PUT /cart/:id
    def update    
      resp = Caboose::StdClass.new
      
      order_id = session['cart_id']
      variant_id = params[:id].to_i
      qty = params[:quantity_in_stock].to_i
      
      if (qty == 0)
        OrderLineItem.where(:order_id => order_id, :variant_id => variant_id).delete_all
      else    
        li = OrderLineItem.where(:order_id => order_id, :variant_id => variant_id).first
        li.quantity = qty
        li.save
      end
      render :json => resp
    end
    
    def get_cart
      # Assumes the init_cart method is running in the parent application controller
      return Order.find(session['cart_id'])
    end
  end
end

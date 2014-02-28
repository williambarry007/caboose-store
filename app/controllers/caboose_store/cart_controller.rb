module CabooseStore
  class CartController < ApplicationController
    before_filter :get_order, except: [:update, :delete]
    
    def get_order
      ap session[:cart_id]
      @order = Order.find(session[:cart_id])
      ap @order
    end
    
    # GET /cart/items
    def list
      render json: @order.line_items.collect { |line_item| line_item.cart_info }
    end
    
    # POST /cart/item/:id || Post /cart/item
    def add
      variant = if params[:id]
        Variant.find(params[:id])
      else
        return false unless params[:product_id]
        
        variants = Product.find(params[:product_id]).variants
        variants = variants.where(option1: params[:option1]) if params[:option1]
        variants = variants.where(option2: params[:option2]) if params[:option2]
        variants = variants.where(option3: params[:option3]) if params[:option3]
        
        variants.first
      end
      
      render json: { error: 'There was an error adding item to cart.' } and return if variant.price.nil?
      render json: { error: 'That item is out of stock.' } and return if variant.quantity_in_stock.nil? or variant.quantity_in_stock < 1
      render json: { error: "There are only #{variant.quantity_in_stock} in stock." } and return if params[:quantity].to_i > variant.quantity_in_stock
      
      @order.line_items.each do |line_item|
        if line_item.variant.id == variant.id
          if line_item.quantity + params[:quantity].to_i > variant.quantity_in_stock
            render json: { error: "There are only #{variant.quantity_in_stock} in stock." } and return
          end
          
          line_item.quantity += params[:quantity].to_i
          line_item.save
          render json: line_item.cart_info and return
        end
      end
      
      line_item             = OrderLineItem.new
      line_item.variant     = variant
      line_item.quantity    = 1
      line_item.unit_price  = variant.price
      line_item.variant_sku = variant.sku
      
      @order.line_items << line_item
      @order.save
      
      render json: line_item.cart_info
    end
    
    # PUT /cart/item/:id
    def update
      line_item = OrderLineItem.find(params[:id])
      line_item.update_attributes(params[:attributes])
      line_item.save
      
      render json: line_item
    end
    
    # DELETE /cart/item/:id
    def remove
      line_item = OrderLineItem.find(params[:id])
      render json: line_item.delete
    end
  end
end

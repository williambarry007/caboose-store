module CabooseStore
  class CartController < ApplicationController
    before_filter :get_order, except: [:update, :delete]
    
    def get_order
      ap @order = Order.find(session[:cart_id])
    end
    
    # GET /cart/mobile
    def mobile
      ap @order.line_items.empty?
      render '/caboose_store/cart/empty' and return if @order.line_items.empty?
      render '/caboose_store/cart/index'
    end
    
    # GET /cart/items
    def list
      render json: @order.line_items.collect { |line_item| line_item.cart_info }
    end
    
    # POST /cart/item/:id || Post /cart/item
    def add
      
      # Track down the variant, it's got to be somewhere
      variant = if params[:id]
        Variant.find(params[:id])
      else
        return false unless params[:product_id]
        
        variants = Product.find(params[:product_id]).variants
        variants = variants.where(option1: params[:option1]) if params[:option1]
        variants = variants.where(option2: params[:option2]) if params[:option2]
        variants = variants.where(option3: params[:option3]) if params[:option3]
        
        # There can only be one
        variants.first
      end
      
      # This shouldn't ever happen.. but you know how it goes
      render json: { error: 'There was an error adding the item to your cart.' } and return if variant.price.nil?
      
      # Unless variant is set to ignore quantity, make sure that requested quantity isn't greater than the quantity in stock
      unless variant.ignore_quantity
        render json: { error: 'That item is out of stock.' } and return if variant.quantity_in_stock.nil? or variant.quantity_in_stock < 1
        render json: { error: "There are only #{variant.quantity_in_stock} left in stock." } and return if params[:quantity].to_i > variant.quantity_in_stock
      end
      
      # Check to see if the line item exists
      @order.line_items.each do |line_item|
        
        # Huzzah!
        if line_item.variant.id == variant.id
          
          # Check if the quantity already requested plus the quantity being requested vs the quantity in stock
          unless variant.ignore_quantity
            render json: { error: "There are only #{variant.quantity_in_stock} in stock" } and return if line_item.quantity + params[:quantity].to_i > variant.quantity_in_stock
          end
          
          # Update the line item's quantity
          line_item.quantity += params[:quantity].to_i
          line_item.save
          
          # Otherwise pass back the json response
          render json: line_item.cart_info and return
        end
      end
      
      # When life gives you lemons, make a line item
      line_item             = OrderLineItem.new
      line_item.variant     = variant
      line_item.quantity    = params[:quantity].to_i || 1
      line_item.unit_price  = variant.price
      line_item.variant_sku = variant.sku
      
      # Add to the order
      @order.line_items << line_item
      @order.save
      
      # Otherwise pass back the json response
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

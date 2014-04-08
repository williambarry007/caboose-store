module CabooseStore
  class CartController < CabooseStore::ApplicationController
    
    # GET /cart/mobile
    def mobile
      render '/caboose_store/cart/empty' and return if @order.line_items.empty?
      render '/caboose_store/cart/index'
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
        Variant.find_by_options(params[:product_id], params[:option1], params[:option2], params[:option3])
      end
      
      quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1
      
      # This shouldn't ever happen.. but you know how it goes
      render json: { error: 'There was an error adding the item to your cart.' } and return if variant.nil? or variant.price.nil?
      
      # Unless variant is set to ignore quantity, make sure that requested quantity isn't greater than the quantity in stock
      unless variant.ignore_quantity
        render json: { error: 'That item is out of stock.' } and return if variant.quantity_in_stock.nil? or variant.quantity_in_stock < 1
        render json: { error: "There are only #{variant.quantity_in_stock} left in stock." } and return if quantity > variant.quantity_in_stock
      end
      
      # Check to see if the line item exists
      @order.line_items.each do |line_item|
        
        # Huzzah!
        if line_item.variant.id == variant.id
          
          # Check if the quantity already requested plus the quantity being requested vs the quantity in stock
          unless variant.ignore_quantity
            render json: { error: "There are only #{variant.quantity_in_stock} in stock" } and return if line_item.quantity + quantity > variant.quantity_in_stock
          end
          
          # Update the line item's quantity
          line_item.quantity += quantity
          line_item.save
          
          # Otherwise pass back the json response
          render json: line_item.cart_info and return
        end
      end
      
      # When life gives you lemons, make a line item
      line_item             = OrderLineItem.new
      line_item.variant     = variant
      line_item.quantity    = quantity
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
      quantity  = params[:attributes][:quantity].to_i
      
      if quantity > line_item.variant.quantity_in_stock
        render json: { error: true, message: "There are only #{line_item.variant.quantity_in_stock} left in stock" }
      else
        line_item.update_attribute(:quantity, params[:attributes][:quantity])
        render json: { success: true, item: line_item }
      end
    end
    
    # DELETE /cart/item/:id
    def remove
      line_item = OrderLineItem.find(params[:id])
      render json: line_item.delete
    end
  end
end

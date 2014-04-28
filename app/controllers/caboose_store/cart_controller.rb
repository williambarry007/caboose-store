module CabooseStore
  class CartController < CabooseStore::ApplicationController
    
    # GET /cart/items
    def list
      render :json => @order.line_items.collect { |line_item| line_item.cart_info }
    end
    
    # POST /cart/item/:id || Post /cart/item
    def add
      
      ap params
      
      # Find the variant either with a passed in ID or with it's associated options
      variant = if params[:id]
        Variant.find(params[:id])
      else
        Variant.find_by_options(params[:product_id], params[:option1], params[:option2], params[:option3])
      end
      
      # Ensure that quantity is an integer
      quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1
      
      # This shouldn't ever happen.. but you know how it goes
      render json: { :error => 'There was an error adding the item to your cart.' } and return if variant.nil? or variant.price < 1
      
      # Unless variant is set to ignore quantity, make sure that requested quantity isn't greater than the quantity in stock
      if !variant.ignore_quantity
        render json: { :error => 'That item is out of stock.' } and return if variant.quantity_in_stock.nil? || variant.quantity_in_stock < 1
        render json: { :error => "There are only #{variant.quantity_in_stock} left in stock." } and return if quantity > variant.quantity_in_stock
      end
      
      # Check to see if the line item exists
      catch :break do
        @order.line_items.each do |line_item|
          
          # Huzzah!
          if line_item.variant.id == variant.id
            
            ap "FOUND EXISTING LINE ITEM"
            
            # Check if the quantity already requested plus the quantity being requested vs the quantity in stock
            render :json => { :error => "There are only #{variant.quantity_in_stock} in stock" } and return if !variant.ignore_quantity && line_item.quantity + quantity > variant.quantity_in_stock
            
            # If there are any customizations
            if line_item.customizations.any? || params[:customizations]
              
              ap "CHECK FOR CUSTOMIZATIONS"
              
              # Ensure that customizations were passed and that there is an equivelant number
              break if line_item.customizations.empty? || params[:customizations].nil? || line_item.customizations.count != params[:customizations].count
              
              params[:customizations].each do |customization_id, options|
                customization_variant   = Variant.find_by_options(customization_id, options[:option1], options[:option2], options[:option3])
                line_item_customization = line_item.customizations.find { |customization| customization.variant_id == customization_variant.id }
                
                throw :break if line_item_customization.nil? || customization_variant != line_item_customization.variant || options[:custom_input] != line_item_customization.custom_input
              end
            end
            
            # Update the line item's quantity
            line_item.quantity += quantity
            line_item.save
            
            # Otherwise pass back the json response
            render :json => line_item.cart_info and return
          end
        end
      end
      
      # When life gives you lemons, make a line item
      line_item          = OrderLineItem.new
      line_item.variant  = variant
      line_item.quantity = quantity
      
      # Store in database; necessary before creating customiztion line items for the generated ID
      line_item.save
      
      # Check to see if any customizations were passed
      if !params[:customizations].nil?
        params[:customizations].each do |customization_id, options|
          line_item_customization              = OrderLineItem.new
          line_item_customization.parent_id    = line_item.id
          line_item_customization.variant      = Variant.find_by_options(customization_id, options[:option1], options[:option2], options[:option3])
          line_item_customization.custom_input = options[:custom_input] if options[:custom_input]
          
          # Store in database; this won't be associated with the order, just the parent line item
          line_item_customization.save
        end
      end
      
      # Add to the order
      @order.line_items << line_item
      @order.save
      
      # Otherwise pass back the json response
      render :json => line_item.cart_info
    end
    
    # PUT /cart/item/:id
    def update
      line_item = OrderLineItem.find(params[:id])
      quantity  = params[:attributes][:quantity].to_i
      
      if quantity > line_item.variant.quantity_in_stock
        render :json => { :error => true, :message => "There are only #{line_item.variant.quantity_in_stock} left in stock" }
      else
        line_item.update_attribute(:quantity, params[:attributes][:quantity])
        render :json => { :success => true, :item => line_item }
      end
    end
    
    # DELETE /cart/item/:id
    def remove
      
      # Find the line item
      line_item = OrderLineItem.find(params[:id])
      
      # Delete any and all customizations
      line_item.customizations.each { |customization| customization.delete }
      
      # Notify the client if the line item deleted successfully
      render :json => line_item.delete
    end
  end
end

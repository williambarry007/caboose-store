module CabooseStore
  class CartController < CabooseStore::ApplicationController
    before_filter :get_line_item, :only => [:update, :remove]
    
    def get_line_item
      @line_item = @order.line_items.find(params[:id])
    end
    
    # GET /cart
    def index
      session[:new_cart_items].clear
    end
    
    # GET /cart/new-items
    def new_items
      render :json => { :new_items => session[:new_cart_items] }
    end
    
    # GET /cart/items
    def list
      render :json => { :order => @order }
    end
    
    # POST /cart/add
    def add
      if @order.line_items.exists?(:variant_id => params[:variant_id])
        @line_item = @order.line_items.find_by_variant_id(params[:variant_id])
        @line_item.quantity += params[:quantity] ? params[:quantity].to_i : 1
      else
        @line_item = LineItem.new
        @line_item.variant_id = params[:variant_id]
        @line_item.order_id = @order.id
        @line_item.status = 'pending'
        @line_item.quantity = params[:quantity] ? params[:quantity].to_i : 1
        session[:new_cart_items] << @line_item if @line_item.valid? && !session[:new_cart_items].map(&:id).include?(@line_item.id)
      end
      
      render :json => { :success => @line_item.save, :errors => @line_item.errors.full_messages }
    end
    
    # PUT cart/update
    def update
      @line_item.quantity = params[:quantity].to_i
      render :json => { :success => @line_item.save, :errors => @line_item.errors.full_messages, :line_item => @line_item, :order_subtotal => @order.calculate_subtotal }
    end
    
    # DELETE cart/delete
    def remove
      render :json => { :success => !!@order.line_items.delete(@line_item) }
    end
  end
end


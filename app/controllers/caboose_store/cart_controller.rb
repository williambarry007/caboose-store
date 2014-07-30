module CabooseStore
  class CartController < CabooseStore::ApplicationController
    before_filter :get_line_item, :except => [:index, :add]
    
    def get_line_item
      @line_item = @order.line_items.find(params[:id])
    end
    
    # GET /cart/items
    def index
      respond_to do |format|
        format.html
        format.json { render :json => { :order => @order } }
      end
    end
    
    # POST /cart/add
    def add
      @line_item = if @order.line_items.exists?(:variant_id => params[:variant_id])
        @order.line_items.find_by_variant_id(params[:variant_id])
      else
        LineItem.create(
          :variant_id => params[:variant_id],
          :order_id => @order.id,
          :status => 'pending'
        )
      end
      
      @line_item.quantity += params[:quantity] ? params[:quantity].to_i : 1
      render :json => { :success => @line_item.save, :errors => @line_item.errors.full_messages }
    end
    
    # PUT cart/update
    def update
      @line_item.quantity = params[:quantity].to_i
      render :json => { :success => @line_item.save, :errors => @line_item.errors.full_messages, :line_item => @line_item  }
    end
    
    # DELETE cart/delete
    def remove
      render :json => { :success => !!@order.line_items.delete(@line_item) }
    end
  end
end

